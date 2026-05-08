variable "region" {
  description = "AWS region (must match Sub-comp 01 VPC region)"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "EKS cluster name (used as identifier across Sub-comps)"
  type        = string
  default     = "muoidv-eks"
}

variable "k8s_version" {
  description = "Kubernetes minor version (1.34 = newest stable on AWS 2026-05)"
  type        = string
  default     = "1.34"
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach API Server public endpoint (lab = open, prod = office IP only)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
