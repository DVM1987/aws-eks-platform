# ─────────────────────────────────────────────────────────────────────────────
# Helm Release — AWS Load Balancer Controller
# Provider helm config ở versions.tf đã chỉ vào cluster muoidv-eks
# ─────────────────────────────────────────────────────────────────────────────
resource "helm_release" "lbc" {
  name       = var.lbc_release_name
  namespace  = var.lbc_namespace
  repository = var.lbc_chart_repository
  chart      = "aws-load-balancer-controller"
  version    = var.lbc_chart_version

  # Render values.yaml từ template, inject biến TF vào ${...}
  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      cluster_name    = local.cluster_name
      region          = var.region
      vpc_id          = local.vpc_id
      replica_count   = var.lbc_replica_count
      service_account = var.lbc_release_name
      irsa_role_arn   = aws_iam_role.lbc.arn
    })
  ]

  # Đảm bảo IAM Role + attachment + OIDC Provider tạo XONG mới install Helm
  # → khi pod boot, IRSA assume thành công ngay lần đầu (không CrashLoopBackOff)
  depends_on = [
    aws_iam_role_policy_attachment.lbc,
    aws_iam_openid_connect_provider.eks,
  ]

  # Đợi pod Ready 2/2 mới coi như apply thành công
  wait    = true
  timeout = 300
}
