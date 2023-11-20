variable "env" {
  type    = string
  default = "staging"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "task_count" {
  type    = number
  default = 1
}
