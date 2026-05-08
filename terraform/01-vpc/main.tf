############################################
# 1. VPC
############################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

############################################
# 2. Subnets — 2 public + 2 private across 2 AZs
############################################
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "muoidv-public-1a"
    Tier                                        = "public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "muoidv-public-1b"
    Tier                                        = "public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "${var.region}a"

  tags = {
    Name                                        = "muoidv-private-1a"
    Tier                                        = "private"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "${var.region}b"

  tags = {
    Name                                        = "muoidv-private-1b"
    Tier                                        = "private"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

############################################
# 3. Internet Gateway
############################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "muoidv-igw"
  }
}

############################################
# 4. Route Tables — public has IGW route, private placeholder for NAT (Sub-comp 4)
############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "muoidv-rt-public"
    Tier = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Default route 0.0.0.0/0 -> NAT will be added in Sub-comp 4
  # Local route 10.0.0.0/16 -> local is implicit, AWS auto-creates

  tags = {
    Name = "muoidv-rt-private"
    Tier = "private"
  }
}

############################################
# 5. Route Table Associations
############################################
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}
