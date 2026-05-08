output "nat_gateway_id" {
  description = "NAT Gateway ID (used for debugging route tables)"
  value       = aws_nat_gateway.this.id
}

output "nat_eip" {
  description = "Public Elastic IP attached to NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "private_route_to_nat" {
  description = "Confirmation route 0.0.0.0/0 in private RT now points to NAT"
  value       = "${aws_route.private_to_nat.route_table_id} -> 0.0.0.0/0 -> ${aws_nat_gateway.this.id}"
}
