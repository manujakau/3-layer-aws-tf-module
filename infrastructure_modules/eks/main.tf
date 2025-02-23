module "eks" {
  source = "../../resource_modules/containers/eks"

  create_eks = var.create_eks

  account_id   = var.account_id
  env_name     = var.env_name
  cluster_name = var.cluster_name

  cluster_private_subnets = var.cluster_private_subnets
  cluster_public_subnets  = var.cluster_public_subnets

  cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr
  cluster_version                      = var.cluster_version
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  eks_oidc_root_ca_thumbprint          = var.eks_oidc_root_ca_thumbprint

  tags = var.tags
}
