include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//composition/network"
}

inputs = {
  create_vpc           = true
  cidr                 = "10.1.0.0/16"
  azs                  = ["eu-central-1a", "eu-central-1c", "eu-central-1b"]
  public_subnets       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  isolate_subnets      = ["10.1.105.0/24", "10.1.106.0/24", "10.1.107.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_ingress_with_cidr_blocks = []

  create_vpn              = false
  create_customer_gateway = false
  customer_gateways = {
    IP1 = {
      bgp_asn    = 65000
      ip_address = "192.168.1.2"
    }
  }
}
