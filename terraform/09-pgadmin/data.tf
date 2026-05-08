data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-02-eks/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_route53_zone" "sub_zone" {
  name         = var.sub_zone_name
  private_zone = false
}

data "aws_acm_certificate" "wildcard" {
  domain      = var.acm_cert_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}
