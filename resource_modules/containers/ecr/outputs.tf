output "ecr_repository_url" {
  description = "URL of the ECR Repository."
  value       = length(aws_ecr_repository.this) > 0 ? aws_ecr_repository.this[0].repository_url : null
}
