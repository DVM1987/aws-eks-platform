resource "kubernetes_namespace_v1" "muoidv_data" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "muoidv.lab/sub-component"     = "08-postgresql"
    }
  }
}
