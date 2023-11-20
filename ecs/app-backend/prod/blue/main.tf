terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "app_backend_blue" {
  family             = "app-backend-blue"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::account-id:role/ecs_task_exec_role"
  container_definitions = templatefile("task-definition.json.tpl",
  { tag : var.tag })
}

resource "aws_ecs_service" "app_backend_blue_svc" {
  name                               = "app-backend-blue-svc"
  launch_type                        = "EC2"
  cluster                            = "prod"
  task_definition                    = aws_ecs_task_definition.app_backend.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}
