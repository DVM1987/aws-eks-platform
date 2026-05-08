output "ebs_csi_iam_role_arn" {
  description = "ARN của IRSA role gắn cho EBS CSI Controller pod (debug + reuse Sub-comp khác nếu cần)"
  value       = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_iam_role_name" {
  description = "Tên IAM role IRSA (thuận tiện CLI describe/detach khi cleanup)"
  value       = aws_iam_role.ebs_csi.name
}

output "ebs_csi_addon_version" {
  description = "EKS Add-on version đã pin (track khi K8s upgrade)"
  value       = aws_eks_addon.ebs_csi.addon_version
}

output "ebs_csi_addon_arn" {
  description = "ARN của EKS Add-on (debug AWS Console)"
  value       = aws_eks_addon.ebs_csi.arn
}

output "storageclass_name" {
  description = "Tên StorageClass default cluster đang dùng"
  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
}

output "storageclass_provisioner" {
  description = "Provisioner SC trỏ tới (ebs.csi.aws.com)"
  value       = kubernetes_storage_class_v1.gp3.storage_provisioner
}
