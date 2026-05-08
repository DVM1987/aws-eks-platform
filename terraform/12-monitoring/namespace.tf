resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.monitoring_namespace

    labels = {
      "app.kubernetes.io/name"       = "kube-prometheus-stack"
      "app.kubernetes.io/managed-by" = "terraform"
      "muoidv.io/sub-comp"           = "12-monitoring"
    }
  }
}
