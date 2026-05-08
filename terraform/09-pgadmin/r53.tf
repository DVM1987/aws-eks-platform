resource "aws_route53_record" "pgadmin" {
  zone_id = data.aws_route53_zone.sub_zone.zone_id
  name    = var.pgadmin_host
  type    = "A"

  alias {
    name                   = data.aws_lb.muoidv_public.dns_name
    zone_id                = data.aws_lb.muoidv_public.zone_id
    evaluate_target_health = true
  }
}
