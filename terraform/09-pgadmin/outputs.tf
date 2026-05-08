output "pgadmin_url" {
  value       = "https://${var.pgadmin_host}"
  description = "Public HTTPS URL for pgAdmin"
}

output "pgadmin_host" {
  value = var.pgadmin_host
}

output "namespace_name" {
  value = kubernetes_namespace_v1.muoidv_pgadmin.metadata[0].name
}

output "release_name" {
  value = helm_release.pgadmin.name
}

output "chart_version" {
  value = helm_release.pgadmin.version
}

output "alb_dns_name" {
  value = data.aws_lb.muoidv_public.dns_name
}

output "alb_zone_id" {
  value = data.aws_lb.muoidv_public.zone_id
}

output "ingress_hostname" {
  value = try(data.kubernetes_ingress_v1.pgadmin.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "acm_cert_arn" {
  value = data.aws_acm_certificate.wildcard.arn
}

output "pgadmin_admin_email" {
  value     = var.pgadmin_admin_email
  sensitive = true
}
