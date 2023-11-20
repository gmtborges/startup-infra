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


resource "aws_ecs_task_definition" "grafana_prom" {
  family             = "grafana_prom"
  network_mode       = "bridge"
  task_role_arn      = "arn:aws:iam::${local.account_id}:role/ecs_traefik_role"
  execution_role_arn = "arn:aws:iam::${local.account_id}:role/ecs_task_exec_role"
  container_definitions = templatefile("task-definition.json.tpl",
    { env : var.env, account_id : local.account_id, aws_region : var.aws_region }
  )

  volume {
    name = "prom-config"
  }

  volume {
    name = "alert-config"
  }

  volume {
    name = "prometheus-vol"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/ebs"
      driver_opts = {
        "volumetype" = "gp3"
        "size"       = "5"
      }
    }
  }

  volume {
    name = "grafana-vol"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/ebs"
      driver_opts = {
        "volumetype" = "gp3"
        "size"       = "1"
      }
    }
  }
}

resource "aws_ecs_service" "grafana_prom_alert_svc" {
  name                               = "grafana-prom-alert-svc"
  cluster                            = var.env
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.grafana_prom.arn
  launch_type                        = "EC2"
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  force_new_deployment               = true
}
