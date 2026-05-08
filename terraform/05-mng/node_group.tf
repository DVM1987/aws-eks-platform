# ─────────────────────────────────────────────────────────────────────────────
# EKS Managed Node Group — dùng Custom LT ở launch_template.tf
#
# Workflow của MNG khi apply:
#   1. AWS đọc LT (KHÔNG có ImageId) + ami_type ở đây → resolve AMI ID thực tế
#      = AMI EKS-optimized AL2023 mới nhất cho region này.
#   2. AWS tạo ASG ẩn ở dưới với LT đã merge cluster info + user_data của mình.
#   3. ASG đẻ EC2 → cloud-init chạy → nodeadm đọc YAML → kubelet boot với --max-pods=110.
#   4. kubelet gọi cluster endpoint join → Control Plane verify IAM role node →
#      tự động đẩy node entry vào ConfigMap aws-auth → node Ready.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_node_group" "default" {
  cluster_name    = local.cluster_name
  node_group_name = "muoidv-mng-default"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.private_subnet_ids   # 2 subnet cross-AZ 1a + 1b

  # ───── Custom LT (KHÔNG kèm image_id, để ami_type resolve)
  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  # ───── AMI type — source-of-truth khi LT thiếu image_id
  # AL2023_x86_64_STANDARD = Amazon Linux 2023, x86_64, no GPU, no Bottlerocket.
  ami_type      = "AL2023_x86_64_STANDARD"
  capacity_type = "ON_DEMAND"

  # ───── Scaling — desired = số node sẽ chạy ngay khi apply xong
  scaling_config {
    desired_size = var.desired_size   # 2
    min_size     = var.min_size       # 2
    max_size     = var.max_size       # 4
  }

  # ───── Update strategy — rolling, max 1 node down/lúc (giảm downtime)
  update_config {
    max_unavailable = 1
  }

  # ───── K8s labels gắn vào node — schedulingrule "role=general"
  labels = {
    role     = "general"
    capacity = "on-demand"
  }

  # ───── Lifecycle — bỏ qua drift của desired_size
  # Sau này cluster autoscaler / Karpenter có thể scale up/down node,
  # nếu TF thấy desired_size khác state cũ sẽ revert về 2 → conflict.
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # ───── Đảm bảo IAM policy attach XONG TRƯỚC KHI tạo MNG
  # Nếu không depends_on, TF có thể tạo MNG trước attachment → node boot
  # nhưng kubelet không có quyền DescribeCluster → join fail.
  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr,
  ]

  tags = {
    Name = "muoidv-mng-default"
  }
}
