# ─────────────────────────────────────────────────────────────────────────────
# Resource 1/4 — IAM OIDC Provider
# Register cluster's OIDC issuer làm IdP cho IAM (cho phép STS verify JWT của pod SA)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_openid_connect_provider" "eks" {
  url             = local.oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.oidc_thumbprint]

  tags = {
    Name = "muoidv-eks-oidc-provider"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Resource 2/4 — IAM Permission Policy
# Load JSON 16-statement từ file iam-policy.json (download từ GitHub aws-load-balancer-controller v3.3.0)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_policy" "lbc" {
  name        = var.lbc_iam_policy_name
  description = "Permission policy for AWS Load Balancer Controller v${var.lbc_chart_version}"
  policy      = file("${path.module}/files/iam-policy.json")

  tags = {
    Name = var.lbc_iam_policy_name
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Trust Policy (data source — KHÔNG tạo resource, chỉ render JSON)
# Cho phép pod có ServiceAccount kube-system/aws-load-balancer-controller
# assume role này qua sts:AssumeRoleWithWebIdentity
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "lbc_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${var.lbc_namespace}:${var.lbc_release_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Resource 3/4 — IAM Role IRSA
# Trust policy embed lúc tạo role (qua assume_role_policy)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "lbc" {
  name               = var.lbc_iam_role_name
  description        = "IRSA role for AWS Load Balancer Controller pod (assumed via OIDC)"
  assume_role_policy = data.aws_iam_policy_document.lbc_trust.json

  tags = {
    Name = var.lbc_iam_role_name
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Resource 4/4 — Attach permission policy vào role
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}
