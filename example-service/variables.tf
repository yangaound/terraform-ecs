variable "region" {
  default = "ap-northeast-1"
}
variable "remote_state_key" {}
variable "remote_state_bucket" {}

variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory" {}
variable "cpu" {}
variable "docker_container_port" {}
variable "nginx_profile" {}
variable "desired_task_number" {}
variable "rds_endpoint" {}
variable "rds_username" {}
variable "rds_password" {}
