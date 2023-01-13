provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpn-z" {
  backend = "s3"

  config = {
    region = var.region
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
  }
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name        = "postgres-subnet-group"
  subnet_ids  = data.terraform_remote_state.vpn-z.outputs.private-subnets
  description = "RDS subnet group"
}

resource "aws_db_parameter_group" "db-parameter-group" {
  name   = "postgresql-parameter-group"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "postgres-db-instance" {
  allocated_storage       = 30
  engine                  = "postgres"
  instance_class          = "db.m5.large"
  identifier_prefix       = "postgresql"
  db_name                 = "postgres"
  username                = var.rds_username
  password                = var.rds_password
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-group.name
  parameter_group_name    = aws_db_parameter_group.db-parameter-group.name
  apply_immediately       = true
  multi_az                = "false"
  vpc_security_group_ids  = [aws_security_group.postgresql.id]
  storage_type            = "gp2"
  backup_retention_period = 30
  skip_final_snapshot     = true
  tags = {
    Name = "postgres-db-instance"
  }
}
