data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0
  name  = var.ecs_cluster_name
  tags  = var.tags
}

resource "aws_iam_role" "ecs_task_execution_role" {
  count              = var.create_ecs ? 1 : 0
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count      = var.create_ecs ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "demo_app_task" {
  count                    = var.create_ecs ? 1 : 0
  family                   = var.task_famliy
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.task_name}",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[0].arn
}

resource "aws_alb" "application_load_balancer" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets = [
    "${var.subnets[0]}",
    "${var.subnets[1]}",
    "${var.subnets[2]}"
  ]
  security_groups = [var.alb_seurity_group_id]
}
