variable "create_ecr" {
  description = "Is Create Amazon ECR"
  type        = bool
  default     = false
}

variable "ecr_repository_name" {
  description = "Name of the Repository. prefix"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}