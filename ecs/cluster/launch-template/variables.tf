variable "cluster" {
  type    = string
  default = "staging"
}

variable "snapshot_id" {
  type    = string
  default = "snap-0e0210b25f26b7449"
}

variable "ami_id" {
  type    = string
  default = "ami-098accd64a8a385dc"
}

variable "ec2_key" {
  type    = string
  default = "staging-ohio-key"
}

variable "aws_sg" {
  type    = string
  default = "sg-040954d3bdd46a72f"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}
