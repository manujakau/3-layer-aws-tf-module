variable "create_sg" {
  description = "Whether to create the security group"
  type        = bool
  default     = false
}

variable "sg_alb_name" {
  description = "Security group name"
  type        = string
  default     = ""
}

variable "sg_alb_description" {
  description = "Security group description"
  type        = string
  default     = ""
}

variable "sg_alb_ingress_rules" {
  description = "List of ingress rules"
  type        = any
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type        = any
  default     = []
}

variable "sg_service_name" {
  description = "Security group name"
  type        = string
  default     = ""
}

variable "sg_service_description" {
  description = "Security group description"
  type        = string
  default     = ""
}

variable "create_ecs" {
  description = "Is Create Amazon ECS"
  type        = bool
  default     = false
}

variable "ecs_cluster_name" {
  description = "Name of the ECS. prefix"
  type        = string
  default     = ""
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

variable "container_port" {
  description = "Container Port"
  type        = number
}

variable "alb_name" {
  description = "Application Loadbalancer Name"
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

variable "vpc_id" {
  description = "VPC ID from the network unit"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from the network unit"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "Repository URL from the ecr unit"
  type        = string
}
