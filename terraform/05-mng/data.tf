# ─────────────────────────────────────────────────────────────────────────────
# Read outputs từ Sub-comp 01 (VPC) — lấy private subnet để đặt worker node
# ─────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-01-vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Read outputs từ Sub-comp 02 (EKS cluster) — lấy cluster name + cluster SG
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
# Locals — gom các giá trị remote_state lại để các file khác xài cho gọn
# ─────────────────────────────────────────────────────────────────────────────
locals {
  cluster_name              = data.terraform_remote_state.eks.outputs.cluster_name
  cluster_security_group_id = data.terraform_remote_state.eks.outputs.cluster_security_group_id
  private_subnet_ids        = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}
