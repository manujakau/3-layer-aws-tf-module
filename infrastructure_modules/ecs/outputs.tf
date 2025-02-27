output "security_group_alb_id" {
  description = "ALB Security Group ID"
  value       = module.sg_alb.security_group_id
}

output "service_security_group_id" {
  description = "Service Security Group ID"
  value       = module.sg_service.security_group_id
}