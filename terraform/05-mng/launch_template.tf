# ─────────────────────────────────────────────────────────────────────────────
# Custom Launch Template cho EKS MNG worker node
#
# ⚠️ PITFALL VÀNG #2 (Lab A 2026-05-02):
#   - TUYỆT ĐỐI KHÔNG khai `image_id` ở đây.
#   - LT có ImageId → MNG KHÔNG inject cluster info vào user_data
#     → nodeadm fatal "Name is missing in cluster configuration"
#     → node không bao giờ join cluster.
#   - Để MNG tự pick AMI theo arg `ami_type` ở aws_eks_node_group.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_launch_template" "node" {
  name_prefix = "muoidv-eks-node-"
  description = "Custom LT cho MNG — bật Prefix Delegation (--max-pods=${var.node_max_pods})"

  instance_type          = var.node_instance_type
  vpc_security_group_ids = [local.cluster_security_group_id]

  # ───── Root EBS volume — gp3 50GB cho image pull + log buffer
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_disk_size_gb
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      delete_on_termination = true
    }
  }

  # ───── IMDSv2 required (security best practice — chặn SSRF lấy creds)
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }

  # ───── User data MIME multipart — nodeadm config override kubelet --max-pods
  # Đọc từ file template (flush-left, tránh indent pitfall MIME parser).
  # MNG sẽ MERGE block này với block cluster info AWS auto-inject (name + endpoint + CA).
  user_data = base64encode(templatefile("${path.module}/templates/user_data_nodeadm.tpl", {
    max_pods = var.node_max_pods
  }))

  # ───── Tag cho EC2 instance đẻ ra từ LT này (không phải tag cho LT)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "muoidv-eks-node"
    }
  }

  # ───── Tag cho EBS volume đẻ ra
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "muoidv-eks-node-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
