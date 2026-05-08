output "vpc_cni_version" {
  description = "vpc-cni installed version"
  value       = aws_eks_addon.vpc_cni.addon_version
}

output "kube_proxy_version" {
  description = "kube-proxy installed version"
  value       = aws_eks_addon.kube_proxy.addon_version
}

output "coredns_version" {
  description = "coredns installed version"
  value       = aws_eks_addon.coredns.addon_version
}
