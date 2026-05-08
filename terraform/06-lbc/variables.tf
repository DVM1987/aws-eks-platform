variable "region" {
  description = "AWS region của cluster + nơi LBC chạy"
  type        = string
  default     = "ap-southeast-1"
}

variable "lbc_chart_repository" {
  description = "Helm chart repository URL (eks-charts của AWS)"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "lbc_chart_version" {
  description = "Helm chart version. Chart 3.3.0 → app v3.3.0 (scheme mới sau reset đầu 2026, IAM policy 16 statement scope chặt)"
  type        = string
  default     = "3.3.0"
}

variable "lbc_namespace" {
  description = "K8s namespace cài LBC. Standard: kube-system (component cluster-level)"
  type        = string
  default     = "kube-system"
}

variable "lbc_release_name" {
  description = "Helm release name. PHẢI = service account name vì trust policy IRSA bind theo sub claim system:serviceaccount:<ns>:<sa-name>"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "lbc_replica_count" {
  description = "Số replica LBC pod. 2 = HA active-standby qua leader election (Lease coordination.k8s.io)"
  type        = number
  default     = 2
}

variable "lbc_iam_role_name" {
  description = "Tên IAM role IRSA cho LBC pod (assume qua OIDC, attach policy quản ALB/SG/TG)"
  type        = string
  default     = "muoidv-lbc-irsa"
}

variable "lbc_iam_policy_name" {
  description = "Tên IAM policy chứa ~80 action ELB v2 + EC2 SG/Subnet/Tag + WAFv2/Shield/ACM"
  type        = string
  default     = "muoidv-lbc-policy"
}
