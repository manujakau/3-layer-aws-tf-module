variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "create_ecr" {
  description = "Controls if VPN should be created"
  default     = false
}

variable "ecr_repository_name" {
  description = "Name of the Repository. prefix"
  default     = ""
}
