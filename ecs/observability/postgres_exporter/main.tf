
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}


resource "aws_ecs_task_definition" "postgres" {
  family                = "postgres"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::${local.account_id}:role/ecs_task_exec_role"
  container_definitions = file("task-definition.json")
}

resource "aws_ecs_service" "postgres_exporter_svc" {
  name                               = "postgres-exporter-svc"
  cluster                            = var.env
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.postgres.arn
  launch_type                        = "EC2"
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  force_new_deployment               = true
}
