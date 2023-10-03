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

resource "aws_ecs_task_definition" "ci_runner" {
  family                = "ci-runner"
  network_mode          = "bridge"
  execution_role_arn    = "arn:aws:iam::322700331992:role/ecsTaskExecutionRole"
  container_definitions = file("task-definition.json")

  volume {
    name      = "dockersock"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "ci_runner_svc" {
  name                               = "ci-runner-svc"
  cluster                            = "staging"
  task_definition                    = aws_ecs_task_definition.ci_runner.arn
  desired_count                      = var.task_count
  launch_type                        = "EC2"
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
}
