# ─────────────────────────────────────────────────────────────────────────────
# Read outputs từ Sub-comp 02 (EKS cluster) — lấy cluster_name làm key tra cứu
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
# Query LIVE EKS cluster — lấy endpoint + CA cert + OIDC issuer URL
# Dùng cho: helm provider (host + ca), IAM OIDC Provider (issuer url)
# ─────────────────────────────────────────────────────────────────────────────
data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# ─────────────────────────────────────────────────────────────────────────────
# Fetch X.509 cert chain từ OIDC issuer URL → tự tính thumbprint
# Thay cho hardcode "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" (Amazon Root CA)
# AWS có thể xoay CA → fetch dynamic an toàn hơn
# ─────────────────────────────────────────────────────────────────────────────
data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ─────────────────────────────────────────────────────────────────────────────
# Locals — gom giá trị reuse nhiều lần ở iam.tf + helm.tf
# ─────────────────────────────────────────────────────────────────────────────
locals {
  cluster_name     = data.aws_eks_cluster.this.name
  oidc_issuer_url  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_issuer_host = replace(local.oidc_issuer_url, "https://", "")
  oidc_thumbprint  = data.tls_certificate.oidc.certificates[0].sha1_fingerprint
  vpc_id           = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}
