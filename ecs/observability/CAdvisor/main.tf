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


resource "aws_ecs_task_definition" "cadvisor" {
  family                = "cadvisor"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::${local.account_id}:role/ecs_task_exec_role"
  container_definitions = file("task-definition.json")

  volume {
    name      = "root"
    host_path = "/"
  }

  volume {
    name      = "sys"
    host_path = "/sys"
  }

  volume {
    name      = "var_run"
    host_path = "/var/run"
  }

  volume {
    name      = "var_lib_docker"
    host_path = "/var/lib/docker"
  }
}

resource "aws_ecs_service" "cadvisor_svc" {
  name                               = "cadvisor-svc"
  cluster                            = var.env
  scheduling_strategy                = "DAEMON"
  task_definition                    = aws_ecs_task_definition.cadvisor.arn
  launch_type                        = "EC2"
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  force_new_deployment               = true
}
