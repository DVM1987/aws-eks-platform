variable "region" {
  description = "AWS region cluster muoidv chạy"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "Tên EKS cluster — match Sub-comp 02 output"
  type        = string
  default     = "muoidv-eks"
}

variable "ebs_csi_addon_version" {
  description = "Pin EBS CSI Driver Add-on version (tương thích K8s 1.34, query: aws eks describe-addon-versions)"
  type        = string
  default     = "v1.59.0-eksbuild.1"
}

variable "ebs_csi_iam_role_name" {
  description = "Tên IRSA role gắn vào SA ebs-csi-controller-sa"
  type        = string
  default     = "muoidv-ebs-csi-irsa"
}

variable "ebs_csi_managed_policy_arn" {
  description = "AWS-managed policy attach vào IRSA role"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

variable "ebs_csi_service_account" {
  description = "ServiceAccount mà EBS CSI Controller pod dùng (IRSA condition sub)"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "ebs_csi_namespace" {
  description = "Namespace cài EBS CSI Driver (mặc định kube-system)"
  type        = string
  default     = "kube-system"
}

variable "storageclass_name" {
  description = "Tên StorageClass mặc định cluster sẽ dùng"
  type        = string
  default     = "gp3"
}
