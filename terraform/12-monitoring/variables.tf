variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "monitoring_chart_repository" {
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  description = "Helm chart repo prometheus-community"
}

variable "monitoring_chart_version" {
  type        = string
  default     = "84.5.0"
  description = "kube-prometheus-stack chart version (Operator v0.90.1 / Prometheus v3.11.3 / Grafana 13.0.1)"
}

variable "monitoring_release_name" {
  type    = string
  default = "prometheus-stack"
}

variable "monitoring_namespace" {
  type    = string
  default = "monitoring"
}

variable "grafana_admin_password" {
  type      = string
  default   = "MuoidvGrafana2026!"
  sensitive = true
}

variable "grafana_host" {
  type    = string
  default = "grafana.muoidv.do2602.click"
}

variable "alb_group_name" {
  type        = string
  default     = "muoidv-public"
  description = "ALB IngressGroup share với jenkins/app/pgadmin"
}

variable "sub_zone_name" {
  type    = string
  default = "muoidv.do2602.click"
}

variable "acm_cert_domain" {
  type        = string
  default     = "*.muoidv.do2602.click"
  description = "ACM cert wildcard domain"
}

variable "alb_ready_wait_seconds" {
  type        = string
  default     = "90s"
  description = "Buffer cho LBC provision ALB rule sau khi Ingress create"
}

variable "prometheus_pvc_size" {
  type    = string
  default = "10Gi"
}

variable "alertmanager_pvc_size" {
  type    = string
  default = "5Gi"
}

variable "grafana_pvc_size" {
  type    = string
  default = "5Gi"
}

variable "prometheus_retention" {
  type    = string
  default = "7d"
}

variable "prometheus_retention_size" {
  type    = string
  default = "8GiB"
}
