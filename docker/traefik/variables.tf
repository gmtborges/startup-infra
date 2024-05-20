variable "env" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "sa-east-1"
}

variable "task_count" {
  type    = number
  default = 1
}
