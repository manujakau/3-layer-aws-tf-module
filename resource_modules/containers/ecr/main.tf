resource "aws_ecr_repository" "this" {
  count = var.create_ecr ? 1 : 0
  name  = var.ecr_repository_name
  tags  = var.tags
}
