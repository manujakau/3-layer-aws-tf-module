variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "region" {
  type = string
}

variable "role_name" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "application_name" {
  description = "The name of the application."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "region_tag" {
  type = map(any)

  default = {
    "us-east-1"      = "ue1"
    "us-west-1"      = "uw1"
    "eu-west-1"      = "ew1"
    "eu-central-1"   = "ec1"
    "ap-northeast-1" = "apne1"
  }
}


variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "isolate_subnets" {
  description = "A list of isolate subnets inside the VPC"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

## Public Security Group ##
variable "public_ingress_with_cidr_blocks" {
  type = list(any)
}


# Gateways #
variable "create_vpn" {
  description = "Controls if VPN should be created"
  default     = false
}

variable "create_customer_gateway" {
  description = "Controls if VPN should be created"
  default     = false
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  default     = {}
}


# EKS #
variable "create_eks" {
  description = "Is Create Amazon EKS"
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster. prefix"
  default     = ""
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  default     = ""
}

variable "cluster_endpoint_private_access" {
  description = "Amazon EKS private API server endpoint is enabled."
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks can access the Amazon EKS public API server endpoint."
  default     = []
}

variable "eks_oidc_root_ca_thumbprint" {
  default     = ""
  description = "Thumbprint of Root CA for EKS OIDC"
}
