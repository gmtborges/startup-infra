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

resource "aws_ecs_task_definition" "cache" {
  family                   = "cache"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions    = file("task-definition.json")

  volume {
    name = "cache-vol"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "local"
    }
  }
}

resource "aws_ecs_service" "cache_svc" {
  name            = "cache-svc"
  cluster         = "qa"
  task_definition = aws_ecs_task_definition.cache.arn
  desired_count   = var.task_count
}
