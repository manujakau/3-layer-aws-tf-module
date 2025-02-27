module "sg_alb" {
  source = "../../resource_modules/compute/sg/sg_ip"

  create_sg      = var.create_sg
  sg_name        = var.sg_alb_name
  vpc_id         = var.vpc_id
  sg_description = var.sg_alb_description
  ingress_rules  = var.sg_alb_ingress_rules
  egress_rules   = var.egress_rules
}
