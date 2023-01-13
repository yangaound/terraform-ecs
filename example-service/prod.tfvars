# remote state
remote_state_key = "prod/ecs.tfstate"
remote_state_bucket = "yin-long-terraform-state"

# service variables
ecs_service_name = "nginx"
docker_container_port = 80
desired_task_number = "1"
nginx_profile = "default"
memory = 1024
cpu = 512
rds_endpoint = "postgresql20230110092105977800000001.clggo0exioal.ap-northeast-1.rds.amazonaws.com:5432"
rds_username = "TMD_OP"
rds_password = "TMD+123+adm"