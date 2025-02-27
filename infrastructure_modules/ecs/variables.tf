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

# alb sg #
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

# service sg #
variable "sg_service_name" {
  description = "Security group name"
  default = ""
}

variable "sg_service_description" {
  description = "Security group description"
  default     = ""
}

variable "sg_service_ingress_rules" {
  description = "List of ingress rules"
  default = []
}

# common #
variable "egress_rules" {
  description = "List of egress rules"
  default = []
}

# ecs #
variable "create_ecs" {
  description = "Is Create Amazon ECS"
  default     = false
}

variable "ecs_cluster_name" {
  description = "Name of the ECS. prefix"
  default     = ""
}

variable "subnets" {
  description = "A list of subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
}

variable "task_famliy" {
  description = "ECS Task Family"
  type        = string
}

variable "task_name" {
  description = "ECS Task Name"
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR Repo URL"
  type        = string
}

variable "container_port" {
  description = "Container Port"
  type        = number
}

variable "alb_name" {
  description = "Application Loadbalancer Name"
  type        = string
}

variable "alb_seurity_group_id" {
  description = "Application Loadbalancer Security group"
  type        = string
}

variable "alb_target_group_name" {
  description = "Application Loadbalancer Target group name"
  type        = string
}

variable "app_service_name" {
  description = "Application service name"
  type        = string
}

variable "service_security_group_id" {
  description = "Service Security group"
  type        = string
}