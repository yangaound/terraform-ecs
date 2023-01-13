output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc-id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.vpc.outputs.vpc-cidr-block
}

output "hosted_zone_name" {
  value = var.hosted_zone_name
}

output "elb_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.fargate-cluster.name
}

output "ecs_cluster_role_name" {
  value = aws_iam_role.ecs_service.name
}

output "ecs_cluster_role_arn" {
  value = aws_iam_role.ecs_service.arn
}

output "ecs_public_subnets" {
  value = data.terraform_remote_state.vpc.outputs.public-subnets
}

output "ecs_private_subnets" {
  value = data.terraform_remote_state.vpc.outputs.private-subnets
}
