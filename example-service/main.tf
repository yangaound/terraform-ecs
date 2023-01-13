provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "ecs_platform" {
  backend = "s3"

  config = {
    key     = var.remote_state_key
    bucket  = var.remote_state_bucket
    region  = var.region
  }
}

data "template_file" "ecs_task_definition_template" {
  template = file("task_definition.json")

  vars = {
    task_definition_name  = var.ecs_service_name
    ecs_service_name      = var.ecs_service_name
    docker_image_url      = var.docker_image_url
    docker_container_port = var.docker_container_port
    nginx_profile         = var.nginx_profile
    region                = var.region
    rds_username          = var.rds_username
    rds_password          = var.rds_password
    rds_endpoint          = var.rds_endpoint
  }
}

resource "aws_ecs_task_definition" "nginx-task-definition" {
  container_definitions     = data.template_file.ecs_task_definition_template.rendered
  family                    = var.ecs_service_name
  cpu                       = var.cpu
  memory                    = var.memory
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  execution_role_arn        = aws_iam_role.fargate_iam_role.arn
  task_role_arn             = aws_iam_role.fargate_iam_role.arn
}

resource "aws_iam_role" "fargate_iam_role" {
  name = "${var.ecs_service_name}-IAM-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fargate_iam_policy" {
  name = "${var.ecs_service_name}-IAM-Role"
  role = aws_iam_role.fargate_iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = data.terraform_remote_state.ecs_platform.outputs.ecs_cluster_name
  task_definition = var.ecs_service_name
  desired_count   = var.desired_task_number
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets           = data.terraform_remote_state.ecs_platform.outputs.ecs_public_subnets
    security_groups   = [aws_security_group.app_security_group.id]
    assign_public_ip  = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_app_target_group.arn
    container_name   = var.ecs_service_name
    container_port   = var.docker_container_port
  }
}

resource "aws_security_group" "app_security_group" {
  name        = "${var.ecs_service_name}-SG"
  description = "Nginx to communicate in and out"
  vpc_id      = data.terraform_remote_state.ecs_platform.outputs.vpc_id

  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = [data.terraform_remote_state.ecs_platform.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_service_name}-Nginx-SG"
  }
}

resource "aws_lb_target_group" "ecs_app_target_group" {
  name        = "${var.ecs_service_name}-TG"
  port        = var.docker_container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.ecs_platform.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "60"
    timeout             = "30"
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

resource "aws_lb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = data.terraform_remote_state.ecs_platform.outputs.elb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_app_target_group.arn
  }

  condition {
    host_header {
      values = ["${lower(var.ecs_service_name)}.${data.terraform_remote_state.ecs_platform.outputs.hosted_zone_name}"]
    }
  }
}

resource "aws_cloudwatch_log_group" "nginx_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}