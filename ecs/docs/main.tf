terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "docs" {
  family                = "docs"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")
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

resource "aws_ecs_service" "docs_svc" {
  name            = "docs-svc"
  cluster         = "staging"
  task_definition = aws_ecs_task_definition.docs.arn
  desired_count   = var.task_count
}
