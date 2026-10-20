module "ecs" {
  source = "../../infrastructure_modules/ecs"

  create_sg = var.create_sg

  vpc_id = var.vpc_id

  sg_alb_name          = var.sg_alb_name
  sg_alb_description   = var.sg_alb_description
  sg_alb_ingress_rules = var.sg_alb_ingress_rules
  egress_rules         = var.egress_rules

  sg_service_name        = var.sg_service_name
  sg_service_description = var.sg_service_description
  sg_service_ingress_rules = [{
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = module.ecs.security_group_alb_id # cannot take from .tfvars. also act as depends_on.
  }]

  create_ecs                   = var.create_ecs
  ecs_cluster_name             = var.ecs_cluster_name
  subnets                      = var.private_subnet_ids
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  task_famliy                  = var.task_famliy
  task_name                    = var.task_name
  ecr_repo_url                 = var.ecr_repository_url
  container_port               = var.container_port
  alb_name                     = var.alb_name
  alb_seurity_group_id         = module.ecs.security_group_alb_id
  alb_target_group_name        = var.alb_target_group_name
  app_service_name             = var.app_service_name
  service_security_group_id    = module.ecs.service_security_group_id
}
