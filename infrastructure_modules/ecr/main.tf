module "ecr" {
  source = "../../resource_modules/containers/ecr"

  create_ecr          = var.create_ecr
  ecr_repository_name = var.ecr_repository_name
  tags                = var.tags
}
