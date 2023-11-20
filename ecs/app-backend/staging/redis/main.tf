terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_task_definition" "redis" {
  family                = "redis"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

  placement_constraints {
    expression = "attribute:type == dns"
    type       = "memberOf"
  }

  volume {
    name = "redis-staging-vol"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/ebs"
      driver_opts = {
        "volumetype" = "gp3"
        "size"       = "2"
      }
    }
  }
}

resource "aws_ecs_service" "redis_svc" {
  name                               = "redis-svc"
  launch_type                        = "EC2"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.redis.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
