# remote state
remote_state_key    = "prod/vpc.tfstate"
remote_state_bucket = "yin-long-terraform-state"

# domain
hosted_zone_name    = "yinlong.link"
www_cn              = "www-yin-long.s3-website.ap-northeast-1.amazonaws.com"

# ecs
ecs_cluster_name    = "TMD67-ECS-Cluster"
internet_cidr_block = "0.0.0.0/0"
