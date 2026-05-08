resource "kubernetes_namespace_v1" "muoidv_pgadmin" {
  metadata {
    name = var.pgadmin_namespace

    labels = {
      "app.kubernetes.io/name"       = "pgadmin4"
      "app.kubernetes.io/managed-by" = "terraform"
      "muoidv.io/sub-comp"           = "09-pgadmin"
    }
  }
}
