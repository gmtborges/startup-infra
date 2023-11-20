terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "kibana" {
  family                = "kibana"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

}

resource "aws_ecs_service" "kibana_svc" {
  name                               = "kibana-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.kibana.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
