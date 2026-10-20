########################################
# Environment setting
########################################
region   = "eu-central-1"
env      = "prod"
app_name = "tf-moduler"

########################################
# VPC
########################################
create_vpc           = true
cidr                 = "10.1.0.0/16"
azs                  = ["eu-central-1a", "eu-central-1c", "eu-central-1b"]
public_subnets       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] # 256 IPs per subnet
private_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
isolate_subnets      = ["10.1.105.0/24", "10.1.106.0/24", "10.1.107.0/24"]
enable_dns_hostnames = "true"
enable_dns_support   = "true"
enable_nat_gateway   = "true" # need internet connection for worker nodes in private subnets to be able to join the cluster 
single_nat_gateway   = "true"


## Public Security Group ##
public_ingress_with_cidr_blocks = []


########################################
# GATEWAYS
########################################
create_vpn              = false
create_customer_gateway = false
customer_gateways = {
  IP1 = {
    bgp_asn    = 65000
    ip_address = "192.168.1.2"
  },
}



########################################
# EKS
########################################
create_eks                           = false
cluster_name                         = "tf-moduler"
cluster_service_ipv4_cidr            = "172.20.0.0/16"
cluster_version                      = "1.32"
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
eks_oidc_root_ca_thumbprint          = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"



########################################
# ECR
########################################
create_ecr          = true
ecr_repository_name = "tf-moduler"



########################################
# SECURITY GROUPS
########################################
create_sg = true

# alb sg #
sg_alb_name        = "tf-moduler-alb"
sg_alb_description = "moduler-ecs-alb"
sg_alb_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# service sg #
sg_service_name        = "tf-moduler-service"
sg_service_description = "moduler-ecs-service"

# comman sg data #
egress_rules = [{
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}]


########################################
# ECS
########################################
create_ecs                   = true
ecs_cluster_name             = "tf-moduler"
ecs_task_execution_role_name = "tf-moduler-ecs_task_execution"
task_famliy                  = "tf-moduler-task"
task_name                    = "tf-moduler-task"
container_port               = 3000
alb_name                     = "tf-moduler"
alb_target_group_name        = "tf-moduler-tg"
app_service_name             = "tf-moduler-service"
