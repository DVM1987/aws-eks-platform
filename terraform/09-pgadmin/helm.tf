resource "helm_release" "pgadmin" {
  name       = var.pgadmin_release_name
  namespace  = kubernetes_namespace_v1.muoidv_pgadmin.metadata[0].name
  repository = var.pgadmin_chart_repository
  chart      = "pgadmin4"
  version    = var.pgadmin_chart_version

  wait    = true
  timeout = 300

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      admin_email     = var.pgadmin_admin_email
      admin_password  = var.pgadmin_admin_password
      host            = var.pgadmin_host
      alb_group_name  = var.alb_group_name
      acm_cert_arn    = data.aws_acm_certificate.wildcard.arn
    })
  ]
}

resource "time_sleep" "wait_alb" {
  depends_on      = [helm_release.pgadmin]
  create_duration = var.alb_ready_wait_seconds
}

data "kubernetes_ingress_v1" "pgadmin" {
  metadata {
    name      = "${var.pgadmin_release_name}-pgadmin4"
    namespace = kubernetes_namespace_v1.muoidv_pgadmin.metadata[0].name
  }

  depends_on = [time_sleep.wait_alb]
}

data "aws_lbs" "muoidv_public" {
  tags = {
    "elbv2.k8s.aws/cluster" = local.cluster_name
    "ingress.k8s.aws/stack" = var.alb_group_name
  }

  depends_on = [time_sleep.wait_alb]
}

data "aws_lb" "muoidv_public" {
  arn = tolist(data.aws_lbs.muoidv_public.arns)[0]
}
