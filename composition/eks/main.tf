module "eks" {
  source = "../../infrastructure_modules/eks"

  create_eks                           = var.create_eks
  account_id                           = local.account_id
  env_name                             = var.env
  cluster_name                         = var.cluster_name
  cluster_public_subnets               = var.public_subnet_ids
  cluster_private_subnets              = var.private_subnet_ids
  cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr
  cluster_version                      = var.cluster_version
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  tags                                 = local.tags
  eks_oidc_root_ca_thumbprint          = var.eks_oidc_root_ca_thumbprint
}
