# ==============================================================================
# EC2 Outputs
# ==============================================================================

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.monitor.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_instance.monitor.public_ip
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = aws_instance.monitor.private_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.monitor_sg.id
}
