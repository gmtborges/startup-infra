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

resource "aws_ecs_task_definition" "fluent-bit" {
  family                = "fluent-bit"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

  volume {
    name = "config"
  }

}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "private"
  }
}

resource "aws_ecs_service" "fluent_bit_svc" {
  name                               = "fluent-bit-svc"
  launch_type                        = "EC2"
  scheduling_strategy                = "DAEMON"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.fluent-bit.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
