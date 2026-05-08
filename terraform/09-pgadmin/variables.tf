variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "pgadmin_chart_repository" {
  type        = string
  default     = "https://helm.runix.net"
  description = "Helm chart repository URL"
}

variable "pgadmin_chart_version" {
  type        = string
  default     = "1.62.0"
  description = "Chart version (app pgAdmin4 9.13)"
}

variable "pgadmin_release_name" {
  type    = string
  default = "muoidv-pgadmin"
}

variable "pgadmin_namespace" {
  type    = string
  default = "muoidv-pgadmin"
}

variable "pgadmin_admin_email" {
  type    = string
  default = "admin@muoidv.do2602.click"
}

variable "pgadmin_admin_password" {
  type      = string
  default   = "muoidv-pgadmin-2026"
  sensitive = true
}

variable "pgadmin_host" {
  type    = string
  default = "pgadmin.muoidv.do2602.click"
}

variable "alb_group_name" {
  type    = string
  default = "muoidv-public"
}

variable "sub_zone_name" {
  type    = string
  default = "muoidv.do2602.click"
}

variable "acm_cert_domain" {
  type        = string
  default     = "*.muoidv.do2602.click"
  description = "ACM cert wildcard domain (Layer 2 created via Console)"
}

variable "alb_ready_wait_seconds" {
  type        = string
  default     = "90s"
  description = "Buffer time for LBC to provision ALB after Ingress create"
}
