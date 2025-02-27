output "security_group_id" {
  description = "ID of the security group"
  value       = var.create_sg ? aws_security_group.this[0].id : null
}