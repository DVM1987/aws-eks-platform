# ─────────────────────────────────────────────────────────────────────────────
# Read VPC outputs from Sub-comp 01 (public subnet 1a + private route table)
# ─────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "muoidv-tfstate-527055790396"
    key    = "sub-comp-01-vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

locals {
  public_subnet_1a_id    = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  private_route_table_id = data.terraform_remote_state.vpc.outputs.private_route_table_id
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Elastic IP — public IP for NAT Gateway
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "muoidv-eip-nat-1a"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. NAT Gateway — placed in public subnet 1a (single AZ, lab cost)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.public_subnet_1a_id
  connectivity_type = "public"

  tags = {
    Name = "muoidv-nat-1a"
  }

  # NAT GW depends on IGW being attached to VPC; remote_state ensures Sub-comp 01 done.
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. Route — private RT 0.0.0.0/0 -> NAT GW
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_route" "private_to_nat" {
  route_table_id         = local.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
