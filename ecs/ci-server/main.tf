terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "ci_server" {
  family                = "ci-server"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

  volume {
    name = "ci-server-vol"

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

resource "aws_ecs_service" "ci_server_svc" {
  name                               = "ci-server-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.ci_server.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
