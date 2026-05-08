resource "helm_release" "monitoring" {
  name       = var.monitoring_release_name
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = var.monitoring_chart_repository
  chart      = "kube-prometheus-stack"
  version    = var.monitoring_chart_version

  wait    = true
  timeout = 600   # chart nặng 8 component + 3 PVC, default 5m hay timeout

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      grafana_admin_password    = var.grafana_admin_password
      grafana_host              = var.grafana_host
      alb_group_name            = var.alb_group_name
      acm_cert_arn              = data.aws_acm_certificate.wildcard.arn
      prometheus_pvc_size       = var.prometheus_pvc_size
      alertmanager_pvc_size     = var.alertmanager_pvc_size
      grafana_pvc_size          = var.grafana_pvc_size
      prometheus_retention      = var.prometheus_retention
      prometheus_retention_size = var.prometheus_retention_size
    })
  ]
}

resource "time_sleep" "wait_alb" {
  depends_on      = [helm_release.monitoring]
  create_duration = var.alb_ready_wait_seconds
}

data "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "${var.monitoring_release_name}-grafana"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
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
