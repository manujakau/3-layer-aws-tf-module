module "vpc" {
  source = "../../../../infrastructure_modules/vpc"

  name                 = var.app_name
  cidr                 = var.cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  isolate_subnets      = var.isolate_subnets
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  ## Public Security Group ##
  public_ingress_with_cidr_blocks = var.public_ingress_with_cidr_blocks

  ## Private Security Group ##
  # bastion EC2 not created yet
  # bastion_sg_id  = module.bastion.security_group_id

  ## Common tag metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.vpc_tags
  region   = var.region

  ## eks ##
  cluster_name = var.cluster_name
}

module "vpn" {
  source = "../../../../infrastructure_modules/vpn"

  name                    = var.app_name
  tags                    = local.tags
  create_vpn              = var.create_vpn
  create_customer_gateway = var.create_customer_gateway
  customer_gateways       = var.customer_gateways
}

module "eks" {
  source                               = "../../../../infrastructure_modules/eks"

  create_eks                           = var.create_eks
  account_id                           = local.account_id
  env_name                             = var.env
  cluster_name                         = var.cluster_name
  cluster_public_subnets               = module.vpc.public_subnets
  cluster_private_subnets              = module.vpc.private_subnets
  cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr
  cluster_version                      = var.cluster_version
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  tags                                 = local.tags
  eks_oidc_root_ca_thumbprint          = var.eks_oidc_root_ca_thumbprint
}
