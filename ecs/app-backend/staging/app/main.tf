terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "app_backend_latest" {
  family             = "app-backend-latest"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = templatefile("task-definition-latest.json.tpl",
  { tag : var.tag })
}

resource "aws_ecs_service" "app_backend_latest_svc" {
  name                               = "app-backend-staging-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.app_backend_latest.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}
