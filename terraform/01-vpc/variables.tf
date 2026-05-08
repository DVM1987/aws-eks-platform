variable "region" {
  description = "AWS region where VPC is deployed"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "muoidv-vpc"
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC (/16 recommended for EKS)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name — pre-tag subnets for discovery (cluster created in Sub-comp 2)"
  type        = string
  default     = "muoidv-eks"
}
