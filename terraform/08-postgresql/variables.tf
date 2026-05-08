variable "region" {
  type    = string
  default = "ap-southeast-1"
}

# ----- Helm chart -----
variable "chart_repository" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}

variable "chart_name" {
  type    = string
  default = "postgresql"
}

variable "chart_version" {
  type        = string
  default     = "16.7.27"
  description = "Bitnami chart 16.7.27 ship app PG 17.6.0"
}

variable "release_name" {
  type    = string
  default = "muoidv-postgresql"
}

variable "namespace" {
  type    = string
  default = "muoidv-data"
}

# ----- Image override (Bitnami migration 2025-08) -----
variable "image_repository" {
  type        = string
  default     = "bitnamilegacy/postgresql"
  description = "Override sang bitnamilegacy do Bitnami migrate 2025-08, tag bị xoá khỏi docker.io/bitnami/"
}

# ----- DB schema -----
variable "app_username" {
  type        = string
  default     = "muoidvapp"
  description = "App user (KHÔNG superuser) — owner của app database"
}

variable "app_database" {
  type    = string
  default = "muoidvdb"
}

# ----- Passwords (sensitive) -----
variable "postgres_password" {
  type        = string
  default     = "muoidv-pg-admin-2026"
  sensitive   = true
  description = "Superuser postgres password — lab hardcode, prod nên dùng random_password hoặc Vault"
}

variable "app_password" {
  type        = string
  default     = "muoidv-app-2026"
  sensitive   = true
  description = "App user password"
}

# ----- Resources -----
variable "primary_cpu_request" {
  type    = string
  default = "250m"
}

variable "primary_cpu_limit" {
  type    = string
  default = "500m"
}

variable "primary_memory_request" {
  type    = string
  default = "256Mi"
}

variable "primary_memory_limit" {
  type    = string
  default = "512Mi"
}
