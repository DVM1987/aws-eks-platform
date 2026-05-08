output "node_group_name" {
  description = "EKS MNG name (dùng debug + tag)"
  value       = aws_eks_node_group.default.node_group_name
}

output "node_group_arn" {
  description = "ARN của MNG"
  value       = aws_eks_node_group.default.arn
}

output "node_group_status" {
  description = "Status MNG (ACTIVE = node Ready join cluster xong)"
  value       = aws_eks_node_group.default.status
}

output "node_role_arn" {
  description = "ARN IAM role gắn vào worker node (sub-comp sau cần biết để cấp quyền IRSA / SSM)"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Tên IAM role node (gắn extra policy nếu cần — vd CloudWatchAgentServerPolicy cho monitoring)"
  value       = aws_iam_role.node.name
}

output "launch_template_id" {
  description = "ID Custom LT (debug version, view user_data Console)"
  value       = aws_launch_template.node.id
}

output "launch_template_latest_version" {
  description = "Version mới nhất của LT (mỗi đổi user_data sẽ tăng)"
  value       = aws_launch_template.node.latest_version
}

output "scaling_config" {
  description = "Cấu hình scale hiện tại (desired/min/max)"
  value = {
    desired = aws_eks_node_group.default.scaling_config[0].desired_size
    min     = aws_eks_node_group.default.scaling_config[0].min_size
    max     = aws_eks_node_group.default.scaling_config[0].max_size
  }
}
