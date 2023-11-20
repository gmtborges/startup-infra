terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "app_backend_blue" {
  family             = "app-backend-blue"
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::account-id:role/ecs_task_exec_role"
  container_definitions = templatefile("task-definition.json.tpl",
  { tag : var.tag })
}
