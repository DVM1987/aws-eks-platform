variable "region" {
  description = "AWS region (must match Sub-comp 01 + 02)"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cni_version" {
  description = "vpc-cni Add-on version for K8s 1.34 (verified default 2026-05-06)"
  type        = string
  default     = "v1.20.5-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "kube-proxy Add-on version for K8s 1.34 (verified default 2026-05-06)"
  type        = string
  default     = "v1.34.6-eksbuild.2"
}

variable "coredns_version" {
  description = "coredns Add-on version for K8s 1.34 (verified default 2026-05-06)"
  type        = string
  default     = "v1.12.4-eksbuild.10"
}
