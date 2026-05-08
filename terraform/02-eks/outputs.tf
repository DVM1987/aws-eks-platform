output "cluster_name" {
  description = "EKS cluster name (used by Sub-comp 03 nodegroup, kubectl config)"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API Server HTTPS endpoint (kubeconfig 'server' field)"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 CA cert (kubeconfig 'certificate-authority-data' field)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL (used by Sub-comp 03+ for IRSA — LBC, ExternalDNS, EBS CSI)"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Cluster SG auto-created by EKS (Control Plane <-> Node communication)"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "ARN of IAM role used by EKS service (Control Plane)"
  value       = aws_iam_role.cluster.arn
}
