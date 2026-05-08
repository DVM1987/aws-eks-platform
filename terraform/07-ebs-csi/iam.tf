# ─────────────────────────────────────────────────────────────────────────────
# IAM Role IRSA cho EBS CSI Driver Controller
# Trust policy = data.aws_iam_policy_document.ebs_csi_trust (ở data.tf)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "ebs_csi" {
  name        = var.ebs_csi_iam_role_name
  description = "IRSA role for EBS CSI Driver controller in muoidv-eks cluster"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust.json
}

# ─────────────────────────────────────────────────────────────────────────────
# Attach AWS-managed policy AmazonEBSCSIDriverPolicy (16 statement, scope tag)
# ARN cố định AWS, không thay đổi giữa các region
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = var.ebs_csi_managed_policy_arn
}
