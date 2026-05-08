# ─────────────────────────────────────────────────────────────────────────────
# EKS Managed Add-on aws-ebs-csi-driver
# Tương đương CLI hands-on B4: aws eks create-addon --service-account-role-arn ...
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = local.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_addon_version
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  # Đợi attachment apply xong → pod EBS CSI Controller spin up có quyền ngay
  # Nếu thiếu: addon tạo trước, pod call AWS API AccessDenied → restart loop
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi
  ]

  tags = {
    Name = "muoidv-ebs-csi-driver"
  }
}
