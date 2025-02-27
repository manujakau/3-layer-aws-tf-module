variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default     = false
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
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

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
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

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

## Public Security Group ##
variable "public_ingress_with_cidr_blocks" {
  type = list(any)
}

## Private Security Group ##
variable "bastion_sg_id" {
  default = ""
}

## Metatada ##
variable "env" {}
variable "app_name" {}
variable "region" {}

## COMMON TAGS ## 
variable "region_tag" {
  type = map(string)

  default = {
    "us-east-1"      = "ue1"
    "us-west-1"      = "uw1"
    "eu-west-1"      = "ew1"
    "eu-central-1"   = "ec1"
    "ap-northeast-1" = "apne1"
  }
}


# EKS #
variable "cluster_name" {
  description = "Name of the EKS cluster. prefix"
  type        = string
}