# ─────────────────────────────────────────────────────────────────────────────
# Read VPC outputs from Sub-comp 01 (private_subnet_ids needed for control plane ENI)
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
# IAM Role for EKS Control Plane
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─────────────────────────────────────────────────────────────────────────────
# EKS Cluster (control plane)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.k8s_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  # Make sure IAM policy attached BEFORE cluster create — else EKS service
  # cannot ENI / register LB and create fails after 10 min timeout.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}
