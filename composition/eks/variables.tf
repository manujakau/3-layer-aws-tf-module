variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

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

variable "public_subnet_ids" {
  description = "Public subnet IDs from the network unit"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from the network unit"
  type        = list(string)
}
