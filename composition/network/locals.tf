locals {
  tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  vpc_name = "vpc-${var.region_tag}-${var.env}-${var.app_name}"
  vpc_tags = merge(local.tags, { "VPC-Name" = local.vpc_name })
}
