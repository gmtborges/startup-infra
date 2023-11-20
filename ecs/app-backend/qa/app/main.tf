terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "app_backend" {
  family             = "app-backend"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = templatefile("task-definition.json.tftpl",
  { tag : var.tag })
}

resource "aws_ecs_service" "app_backend_svc" {
  name                               = "app-backend-${var.tag}-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.app_backend.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
