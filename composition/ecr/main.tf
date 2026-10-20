module "ecr" {
  source = "../../infrastructure_modules/ecr"

  create_ecr          = var.create_ecr
  tags                = local.tags
  ecr_repository_name = var.ecr_repository_name
}
