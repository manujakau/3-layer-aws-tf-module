output "security_group_alb_id" {
  description = "ALB Security Group ID"
  value       = module.ecs.security_group_alb_id
}

output "service_security_group_id" {
  description = "Service Security Group ID"
  value       = module.ecs.service_security_group_id
}
