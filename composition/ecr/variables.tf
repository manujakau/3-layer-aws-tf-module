variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "create_ecr" {
  description = "Controls if VPN should be created"
  type        = bool
  default     = false
}

variable "ecr_repository_name" {
  description = "Name of the Repository. prefix"
  type        = string
  default     = ""
}
