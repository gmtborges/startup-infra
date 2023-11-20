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

resource "aws_ecs_task_definition" "fluent-bit" {
  family             = "fluent-bit"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::${local.account_id}:role/ecs_task_exec_role"
  container_definitions = templatefile("task-definition.json.tpl",
    { env : var.env, account_id : local.account_id, aws_region : var.aws_region }
  )

  volume {
    name = "config"
  }

}

resource "aws_ecs_service" "fluent_bit_svc" {
  name                               = "fluent-bit-svc"
  launch_type                        = "EC2"
  scheduling_strategy                = "DAEMON"
  cluster                            = var.env
  task_definition                    = aws_ecs_task_definition.fluent-bit.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
