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

resource "aws_launch_template" "ecs_instance_lt" {
  name = "ecs_instance_${var.cluster}_lt"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      iops                  = 3000
      delete_on_termination = true
      snapshot_id           = var.snapshot_id
    }
  }

  iam_instance_profile {
    arn = "arn:aws:iam::${local.account_id}:instance-profile/ecs_instance_role"
  }

  image_id      = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.ec2_key

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.aws_sg]
  }

  placement {
    availability_zone = "${var.aws_region}a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-${var.cluster}"
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster : var.cluster, aws_region : var.aws_region
  }))
}
