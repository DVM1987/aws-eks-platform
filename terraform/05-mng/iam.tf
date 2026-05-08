# ─────────────────────────────────────────────────────────────────────────────
# Trust policy — cho phép EC2 service assume role này
# Worker node = EC2 instance, kubelet/aws-cli trên node sẽ gọi STS:AssumeRole
# qua Instance Metadata Service (IMDSv2) lấy temp credentials.
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    sid     = "AllowEC2ToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# IAM Role — gắn vào EC2 worker node qua Instance Profile (AWS auto-create)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "node" {
  name               = "muoidv-eks-node-role"
  description        = "IAM role for muoidv EKS worker nodes (kubelet + vpc-cni + ECR pull)"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 1 — AmazonEKSWorkerNodePolicy
# Cho phép kubelet describe cluster + DescribeInstances + tag ENI.
# Đây là policy "node là thành viên hợp lệ của cluster".
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 2 — AmazonEKS_CNI_Policy
# Cho phép vpc-cni DaemonSet (chạy trên node) gọi EC2 API:
#   - AssignPrivateIpAddresses / UnassignPrivateIpAddresses
#   - AssignIpv6Addresses (nếu IPv6)
#   - AttachNetworkInterface / CreateNetworkInterface
# Bật Prefix Delegation cũng dùng API này (AssignIpv4Prefixes).
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 3 — AmazonEC2ContainerRegistryReadOnly
# Cho phép kubelet pull image từ ECR (cùng/khác account).
# Lab muoidv chưa có ECR riêng, nhưng image public.ecr.aws cũng cần policy này
# để auth ECR Public registry.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
