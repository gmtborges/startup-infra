#!/bin/bash 
echo ECS_CLUSTER=${cluster} >> /etc/ecs/ecs.config;
docker plugin install rexray/ebs EBS_REGION=${aws_region}  --grant-all-permissions;
sysctl -w vm.max_map_count=262144;
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
