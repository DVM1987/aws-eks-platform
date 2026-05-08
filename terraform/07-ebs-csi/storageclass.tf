# ─────────────────────────────────────────────────────────────────────────────
# StorageClass gp3 — provisioner ebs.csi.aws.com (CSI Driver Add-on)
# Tương đương kubectl apply -f gp3-storageclass.yaml ở hands-on B6
# ─────────────────────────────────────────────────────────────────────────────
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = var.storageclass_name

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }

  # SC chỉ apply được sau khi CSI Driver Add-on ACTIVE
  # → provisioner ebs.csi.aws.com mới registered trong cluster
  depends_on = [
    aws_eks_addon.ebs_csi
  ]
}
