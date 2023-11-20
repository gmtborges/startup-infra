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

resource "aws_ecs_task_definition" "traefik" {
  family             = "traefik"
  network_mode       = "bridge"
  task_role_arn      = "arn:aws:iam::${local.account_id}:role/ecs_traefik_role"
  execution_role_arn = "arn:aws:iam::${local.account_id}:role/ecs_task_exec_role"
  container_definitions = templatefile("task-definition.json.tpl",
    { env : var.env, aws_region : var.aws_region, account_id : local.account_id
  })

  volume {
    name = "config"
  }
}

resource "aws_ecs_service" "traefik_svc" {
  name                               = "traefik-svc"
  cluster                            = var.env
  scheduling_strategy                = "DAEMON"
  task_definition                    = aws_ecs_task_definition.traefik.arn
  launch_type                        = "EC2"
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}
