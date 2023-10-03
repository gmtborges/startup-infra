variable "vpc_id" {
  type    = string
  default = "vpc-02ff8e8729ab41a69"
}

variable "task_count" {
  type    = number
  default = 1
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "dns" {
  type    = string
  default = "custom"
}
