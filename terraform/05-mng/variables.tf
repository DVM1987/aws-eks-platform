variable "region" {
  description = "AWS region where MNG worker nodes are deployed"
  type        = string
  default     = "ap-southeast-1"
}

variable "node_instance_type" {
  description = "EC2 instance type for MNG worker nodes (t3.medium = 2 vCPU / 4GB RAM, đủ cho lab CMS)"
  type        = string
  default     = "t3.medium"
}

variable "node_disk_size_gb" {
  description = "Root EBS volume size per node (GB) — 50GB cho image pull + log buffer"
  type        = number
  default     = 50
}

variable "node_max_pods" {
  description = "Override kubelet --max-pods. 110 = trần kernel khi bật Prefix Delegation (default t3.medium = 17)"
  type        = number
  default     = 110
}

variable "desired_size" {
  description = "Số node mong muốn ban đầu"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Min size cho ASG ẩn của MNG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Max size cho ASG ẩn của MNG (giới hạn cost lab)"
  type        = number
  default     = 4
}
