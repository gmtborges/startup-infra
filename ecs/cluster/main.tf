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

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  name = "/ecs/${var.cluster}-cluster"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster
}
