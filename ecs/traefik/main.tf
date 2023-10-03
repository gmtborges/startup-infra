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
  profile = "app-staging"
  region  = "us-east-2"
}

resource "aws_ecs_task_definition" "traefik" {
  family                = "traefik"
  network_mode          = "bridge"
  task_role_arn         = "arn:aws:iam::322700331992:role/TraefikECSReadAccessRole"
  execution_role_arn    = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")
}

resource "aws_ecs_service" "traefik_svc" {
  name                               = "traefik-svc"
  cluster                            = "staging"
  scheduling_strategy                = "DAEMON"
  task_definition                    = aws_ecs_task_definition.traefik.arn
  launch_type                        = "EC2"
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}
