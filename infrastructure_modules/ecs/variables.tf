variable "create_sg" {
  description = "Whether to create the security group"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "sg_alb_name" {
  description = "Security group name"
  default = ""
}

variable "sg_alb_description" {
  description = "Security group description"
  default     = ""
}

variable "sg_alb_ingress_rules" {
  description = "List of ingress rules"
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  default = []
}