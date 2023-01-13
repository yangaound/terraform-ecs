# remote state
variable "region" {
  default = "ap-northeast-1"
}
variable "remote_state_key" {}
variable "remote_state_bucket" {}

# variables for module
variable "rds_username" {}
variable "rds_password" {}