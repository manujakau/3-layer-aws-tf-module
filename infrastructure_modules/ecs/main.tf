module "sg_alb" {
  source = "../../resource_modules/compute/sg"

  create_sg      = var.create_sg
  vpc_id         = var.vpc_id
  sg_name        = var.sg_alb_name
  sg_description = var.sg_alb_description
  ingress_rules  = var.sg_alb_ingress_rules
  egress_rules   = var.egress_rules
}

module "sg_service" {
  source = "../../resource_modules/compute/sg"

  create_sg      = var.create_sg
  vpc_id         = var.vpc_id
  sg_name        = var.sg_service_name
  sg_description = var.sg_service_description
  ingress_rules  = var.sg_service_ingress_rules
  egress_rules   = var.egress_rules
}

module "ecs" {
  source = "../../resource_modules/containers/ecs"

  create_ecs = var.create_ecs

  vpc_id                       = var.vpc_id
  ecs_cluster_name             = var.ecs_cluster_name
  subnets                      = var.subnets
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  task_famliy                  = var.task_famliy
  task_name                    = var.task_name
  ecr_repo_url                 = var.ecr_repo_url
  container_port               = var.container_port
  alb_name                     = var.alb_name
  alb_seurity_group_id         = var.alb_seurity_group_id
  alb_target_group_name        = var.alb_target_group_name
  app_service_name             = var.app_service_name
  service_security_group_id    = var.service_security_group_id
}
