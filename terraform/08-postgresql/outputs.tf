output "namespace_name" {
  value = kubernetes_namespace_v1.muoidv_data.metadata[0].name
}

output "release_name" {
  value = helm_release.postgresql.name
}

output "chart_version" {
  value = helm_release.postgresql.version
}

# DB connection info - cho Sub-comp 09 pgAdmin + Sub-comp 10 sample app reuse
output "db_host" {
  value       = "${var.release_name}.${var.namespace}.svc.cluster.local"
  description = "FQDN service trong cluster"
}

output "db_port" {
  value = 5432
}

output "db_database" {
  value = var.app_database
}

output "db_app_user" {
  value = var.app_username
}

output "db_secret_name" {
  value       = var.release_name
  description = "K8s Secret name chứa postgres-password + password (chart auto tạo)"
}
