variable "vpc_id" {
  type    = string
  default = "vpc-id"
}

variable "task_count" {
  type    = number
  default = 1
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "custom_sub" {
  type    = string
  default = ""
}
