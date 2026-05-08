# Read EKS cluster info từ Sub-comp 02 state
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-02-eks/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Query EKS cluster live - lấy endpoint + CA cert cho helm/kubernetes provider auth
data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}
