variable "create_eks" {
  description = "Is Create Amazon EKS"
  default     = false
}

variable "account_id" {
  description = "Name of the Enviroment. prefix"
  default     = ""
}

variable "env_name" {
  description = "Name of the Enviroment. prefix"
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster. prefix"
  default     = ""
}

variable "cluster_public_subnets" {
  description = "EKS Public Subnets"
  default     = []
}

variable "cluster_private_subnets" {
  description = "EKS Private Subnets"
  default     = []
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

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "eks_oidc_root_ca_thumbprint" {
  description = "Thumbprint of Root CA for EKS OIDC"
  default     = ""
}
