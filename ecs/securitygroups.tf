resource "aws_security_group" "ecs_task_security_group" {
  name        = "ECS-task-SG"
  description = "TMD67 ECS to communicate in and out"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc-id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cidr_block]
  }

  tags = {
    Name = "ECS-task-SG"
  }
}

resource "aws_security_group_rule" "ingress_ecs_task_security_group_rule" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.ecs_task_security_group.id
  to_port = 80
  source_security_group_id = aws_security_group.elb_security_group.id
  type = "ingress"
}

resource "aws_security_group" "elb_security_group" {
  name          = "ELB-SG"
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc-id

  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ELB-SG"
  }
}
