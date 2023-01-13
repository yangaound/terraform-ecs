resource "aws_security_group" "allow-ssh" {
  vpc_id      = data.terraform_remote_state.vpn-z.outputs.vpc-z_id
  name        = "allow-ssh"
  description = "Allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_security_group" "postgresql" {
  vpc_id      = data.terraform_remote_state.vpn-z.outputs.vpc-z_id
  name        = "postgresql"
  description = "Postgres service to communicate in and out"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.allow-ssh.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "postgresql"
  }
}