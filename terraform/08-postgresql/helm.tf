resource "helm_release" "postgresql" {
  name       = var.release_name
  namespace  = kubernetes_namespace_v1.muoidv_data.metadata[0].name
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  # Đợi pod 1/1 Ready mới mark complete
  wait    = true
  timeout = 300

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      release_name      = var.release_name
      image_repository  = var.image_repository
      postgres_password = var.postgres_password
      app_username      = var.app_username
      app_password      = var.app_password
      app_database      = var.app_database
      cpu_request       = var.primary_cpu_request
      cpu_limit         = var.primary_cpu_limit
      memory_request    = var.primary_memory_request
      memory_limit      = var.primary_memory_limit
    })
  ]

  depends_on = [kubernetes_namespace_v1.muoidv_data]
}
