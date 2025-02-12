########################################
# Environment setting
########################################
region           = "eu-central-1"
role_name        = "Admin"
profile_name     = "default"
env              = "prod"
application_name = "terraform-moduler-deployment"
app_name         = "terraform-moduler-deployment"

########################################
# VPC
########################################
cidr                 = "10.1.0.0/16"
azs                  = ["eu-central-1a", "eu-central-1c", "eu-central-1b"]
public_subnets       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] # 256 IPs per subnet
private_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
isolate_subnets     = ["10.1.105.0/24", "10.1.106.0/24", "10.1.107.0/24"]
enable_dns_hostnames = "true"
enable_dns_support   = "true"
enable_nat_gateway   = "true" # need internet connection for worker nodes in private subnets to be able to join the cluster 
single_nat_gateway   = "true"


## Public Security Group ##
public_ingress_with_cidr_blocks = []