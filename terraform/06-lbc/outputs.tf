output "oidc_provider_arn" {
  description = "IAM OIDC Provider ARN — Sub-comp 07+ (EBS CSI, ExternalDNS, ESO) reuse"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "Issuer URL của OIDC Provider (tham khảo, debug IRSA)"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "lbc_iam_role_arn" {
  description = "ARN của IRSA role gắn cho pod LBC qua annotation SA"
  value       = aws_iam_role.lbc.arn
}

output "lbc_iam_role_name" {
  description = "Tên IAM role IRSA (thuận tiện CLI describe / detach khi cleanup)"
  value       = aws_iam_role.lbc.name
}

output "lbc_iam_policy_arn" {
  description = "ARN của permission policy ~80 action ELB+EC2 SG/Subnet+WAF+ACM"
  value       = aws_iam_policy.lbc.arn
}

output "lbc_helm_release_name" {
  description = "Helm release name (= K8s ServiceAccount name, lookup pod nhanh)"
  value       = helm_release.lbc.name
}

output "lbc_helm_release_namespace" {
  description = "K8s namespace nơi LBC chạy"
  value       = helm_release.lbc.namespace
}

output "lbc_chart_version" {
  description = "Helm chart version đã deploy (chart 3.x.x)"
  value       = helm_release.lbc.version
}

output "lbc_app_version" {
  description = "App version controller binary (tag GitHub aws-load-balancer-controller)"
  value       = helm_release.lbc.metadata[0].app_version
}

output "lbc_helm_release_status" {
  description = "Trạng thái release (deployed/failed/pending)"
  value       = helm_release.lbc.status
}
