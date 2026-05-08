# ─────────────────────────────────────────────────────────────────────────────
# Read EKS cluster name from Sub-comp 02
# ─────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-02-eks/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}

# ─────────────────────────────────────────────────────────────────────────────
# vpc-cni Add-on (with Prefix Delegation enabled)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = local.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# kube-proxy Add-on
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = local.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# ─────────────────────────────────────────────────────────────────────────────
# coredns Add-on — apply SAU Sub-comp 05 MNG (coredns là Deployment, cần node Ready)
# Pitfall đã biết: tạo coredns trước MNG → AWS poll pod Ready vô tận → timeout 20+ phút.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_addon" "coredns" {
  cluster_name                = local.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
