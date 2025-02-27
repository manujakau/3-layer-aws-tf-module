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