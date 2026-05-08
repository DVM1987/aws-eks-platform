output "vpc_id" {
  description = "ID of the VPC (used by Sub-comp 2 EKS, Sub-comp 4 NAT)"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Primary CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (1a, 1b) for ALB and NAT GW"
  value       = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (1a, 1b) for EKS worker nodes"
  value       = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID (0.0.0.0/0 -> IGW)"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID (NAT route added in Sub-comp 4)"
  value       = aws_route_table.private.id
}
