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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
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