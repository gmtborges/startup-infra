terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_ecs_task_definition" "app_backend_task" {
  family             = "app-backend-custom"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions = templatefile("task-definition.json.tftpl",
  { tag : var.tag, dns : var.dns })
}

resource "aws_ecs_service" "app_backend_svc" {
  name                               = "app-backend-staging-${var.dns}-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.app_backend_task.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}
