variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "region" {
  type = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "isolate_subnets" {
  description = "A list of isolate subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

variable "public_ingress_with_cidr_blocks" {
  type = list(any)
}

variable "cluster_name" {
  description = "Name of the EKS cluster. prefix"
  type        = string
  default     = ""
}

variable "create_vpn" {
  description = "Controls if VPN should be created"
  type        = bool
  default     = false
}

variable "create_customer_gateway" {
  description = "Controls if VPN should be created"
  type        = bool
  default     = false
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = any
  default     = {}
}

variable "region_tag" {
  description = "Short region code used in names, e.g. ec1"
  type        = string
}
