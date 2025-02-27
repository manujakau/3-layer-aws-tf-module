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

resource "aws_ecs_task_definition" "app_task" {
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
  count              = var.create_ecs ? 1 : 0
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = var.create_ecs && length(var.subnets) >= 2 ? slice(var.subnets, 0, 2) : var.create_ecs ? var.subnets : []
  security_groups    = ["${var.alb_seurity_group_id}"]
}

resource "aws_lb_target_group" "target_group" {
  count       = var.create_ecs ? 1 : 0
  name        = var.alb_target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  count             = var.create_ecs ? 1 : 0
  load_balancer_arn = aws_alb.application_load_balancer[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[0].arn
  }
}

resource "aws_ecs_service" "app_service" {
  count           = var.create_ecs ? 1 : 0
  name            = var.app_service_name
  cluster         = aws_ecs_cluster.this[0].id
  task_definition = aws_ecs_task_definition.app_task[0].arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group[0].arn
    container_name   = aws_ecs_task_definition.app_task[0].family
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.create_ecs && length(var.subnets) >= 2 ? slice(var.subnets, 0, 2) : var.create_ecs ? var.subnets : []
    assign_public_ip = true
    security_groups  = ["${var.service_security_group_id}"]
  }
}
