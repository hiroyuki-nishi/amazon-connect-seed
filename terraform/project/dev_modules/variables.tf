variable "env" {}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "prefix" {
  type    = string
  default = "prefix"
}

variable "project_name" {
  type    = string
  default = "xxx"
}

variable "lambdas_security_group_id" {
  type    = string
}
