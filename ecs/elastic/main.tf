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

resource "aws_ecs_task_definition" "elasticsearch" {
  family                = "elasticsearch"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

  placement_constraints {
    expression = "attribute:type == dns"
    type       = "memberOf"
  }

  volume {
    name = "elasticsearch-vol"

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
}

resource "aws_ecs_service" "elasticsearch_svc" {
  name                               = "elasticsearch-svc"
  cluster                            = "staging"
  launch_type                        = "EC2"
  task_definition                    = aws_ecs_task_definition.elasticsearch.arn
  desired_count                      = var.task_count
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
