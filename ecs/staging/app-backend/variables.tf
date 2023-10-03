variable "vpc_id" {
  type    = string
  default = "vpc-02ff8e8729ab41a69"
}

variable "task_count" {
  type    = number
  default = 2
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "custom_sub" {
  type    = string
  default = ""
}
