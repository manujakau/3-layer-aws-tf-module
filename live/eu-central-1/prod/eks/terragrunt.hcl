include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//composition/eks"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    public_subnets  = ["subnet-00000000000000001"]
    private_subnets = ["subnet-00000000000000002"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  public_subnet_ids  = dependency.network.outputs.public_subnets
  private_subnet_ids = dependency.network.outputs.private_subnets

  create_eks                           = false
  cluster_service_ipv4_cidr            = "172.20.0.0/16"
  cluster_version                      = "1.32"
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  eks_oidc_root_ca_thumbprint          = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}
