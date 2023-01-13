#!/bin/sh

REGION=${REGION:=ap-northeast-1}
SERVICE_NAME=${SERVICE_NAME:=tmd67_oauth2}
SERVICE_TAG=${SERVICE_TAG:=latest}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:?}

VAR_FILE=${VAR_FILE:=prod.tfvars}
STATE_CONF=${STATE_CONF:=state.config}

ECR_REPO_URL=${ECR_REPO_URL:=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$SERVICE_NAME}

if [ "$1" = "plan" ];then
    terraform init -backend-config=$STATE_CONF
    terraform plan -var-file=$VAR_FILE -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG"
elif [ "$1" = "deploy" ];then
    terraform init -backend-config=$STATE_CONF
    terraform apply -var-file=$VAR_FILE -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
elif [ "$1" = "destroy" ];then
    terraform init -backend-config=$STATE_CONF
    terraform destroy -var-file=$VAR_FILE -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
fi
