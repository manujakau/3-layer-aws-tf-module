include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//composition/ecs"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id          = "vpc-00000000000000000"
    private_subnets = ["subnet-00000000000000002"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "ecr" {
  config_path = "../ecr"

  mock_outputs = {
    ecr_repository_url = "000000000000.dkr.ecr.eu-central-1.amazonaws.com/mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  vpc_id             = dependency.network.outputs.vpc_id
  private_subnet_ids = dependency.network.outputs.private_subnets
  ecr_repository_url = dependency.ecr.outputs.ecr_repository_url

  create_sg          = true
  sg_alb_name        = "tf-moduler-alb"
  sg_alb_description = "moduler-ecs-alb"
  sg_alb_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  sg_service_name        = "tf-moduler-service"
  sg_service_description = "moduler-ecs-service"
  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  create_ecs                   = true
  ecs_cluster_name             = "tf-moduler"
  ecs_task_execution_role_name = "tf-moduler-ecs_task_execution"
  task_famliy                  = "tf-moduler-task"
  task_name                    = "tf-moduler-task"
  container_port               = 3000
  alb_name                     = "tf-moduler"
  alb_target_group_name        = "tf-moduler-tg"
  app_service_name             = "tf-moduler-service"
}
