output "grafana_url" {
  value       = "https://${var.grafana_host}"
  description = "Public HTTPS URL for Grafana"
}

output "grafana_host" {
  value = var.grafana_host
}

output "namespace_name" {
  value = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "release_name" {
  value = helm_release.monitoring.name
}

output "chart_version" {
  value = helm_release.monitoring.version
}

output "alb_dns_name" {
  value = data.aws_lb.muoidv_public.dns_name
}

output "alb_zone_id" {
  value = data.aws_lb.muoidv_public.zone_id
}

output "ingress_hostname" {
  value = try(data.kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "acm_cert_arn" {
  value = data.aws_acm_certificate.wildcard.arn
}

output "grafana_admin_password" {
  value     = var.grafana_admin_password
  sensitive = true
}
