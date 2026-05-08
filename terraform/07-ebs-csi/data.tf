# ─────────────────────────────────────────────────────────────────────────────
# Đọc state Sub-comp 02 (EKS cluster) — lấy cluster_name làm key tra cứu
# ─────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-02-eks/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Đọc state Sub-comp 06 (LBC) — REUSE OIDC Provider IAM ARN đã đăng ký
# Tránh tạo trùng aws_iam_openid_connect_provider (duplicate URL = lỗi)
# ─────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "lbc" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-06-lbc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Query LIVE EKS cluster — lấy endpoint + CA cert (cho provider kubernetes)
# ─────────────────────────────────────────────────────────────────────────────
data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# ─────────────────────────────────────────────────────────────────────────────
# Trust policy HCL native (thay JSON file ở hands-on B1)
# Validate syntax tại plan, interpolate ${oidc_host} cleanly
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "ebs_csi_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.terraform_remote_state.lbc.outputs.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${var.ebs_csi_namespace}:${var.ebs_csi_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Locals — gom giá trị reuse nhiều lần
# ─────────────────────────────────────────────────────────────────────────────
locals {
  cluster_name     = data.aws_eks_cluster.this.name
  oidc_issuer_url  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_issuer_host = replace(local.oidc_issuer_url, "https://", "")
}
