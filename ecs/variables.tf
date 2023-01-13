# remote state
variable "region" {
  default = "ap-northeast-1"
}
variable "remote_state_key" {}
variable "remote_state_bucket" {}

# ecs
variable "ecs_cluster_name" {}
variable "internet_cidr_block" {}

# elb
variable "hosted_zone_name" {}
variable "www_cn" {}
