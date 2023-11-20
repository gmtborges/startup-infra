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

resource "aws_iam_role" "ecs_traefik_role" {
  name = "ecs_traefik_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "traefik_ecs_read_access"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TraefikECSReadAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:ListClusters",
                "ecs:DescribeClusters",
                "ecs:ListTasks",
                "ecs:DescribeTasks",
                "ecs:DescribeContainerInstances",
                "ecs:DescribeTaskDefinition",
                "ec2:DescribeInstances",
                "ssm:DescribeInstanceInformation"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
  }
}


resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecs_task_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "s3_envs_configs_access"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::app-envs/*",
              "arn:aws:s3:::app-configs/*"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation"
          ],
          "Resource": [
              "arn:aws:s3:::app-envs",
              "arn:aws:s3:::app-configs"
          ]
      }
  ]
}
  EOF
  }

  inline_policy {
    name   = "s3_prod_envs_access"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::app-prod-envs/*"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation"
          ],
          "Resource": [
              "arn:aws:s3:::app-prod-envs"
          ]
      }
  ]
}
  EOF
  }

  inline_policy {
    name   = "ssm_parameter_access"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "ssm:GetParameters",
        "Resource": [
            "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/*"
        ]
      }
  ]
}
EOF
  }
}

resource "aws_iam_role_policy_attachment" "ecr-attach" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "ebs_rexray_access"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DetachVolume",
                "ec2:AttachVolume",
                "ec2:CopySnapshot",
                "ec2:DeleteSnapshot",
                "ec2:ModifyVolumeAttribute",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeSnapshotAttribute",
                "ec2:CreateTags",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumeAttribute",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:ModifySnapshotAttribute",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeVolumes",
                "ec2:CreateSnapshot"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  }
}

resource "aws_iam_role_policy_attachment" "ecs-attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}
