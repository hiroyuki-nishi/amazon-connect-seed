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

variable "database_name" {
  type    = string
  default = "prefix_xxx"
}

#########################
## VPC
#########################
variable "vpc_id" {
  type = string
}

variable "vpc_public_subnet_id" {
  type = string
}

variable "vpc_private_subnet_ids" {
  type = list(string)
}

#########################
## RDS
#########################
variable "workspace_cluster_instances" {
  type = map(any)

  default = {
    prod    = "2"
    dev     = "1"
    default = "1"
  }
}

#########################
## Amazon Connect
#########################
variable "instance_id" {
  type = map(any)

  # NOTE: 指定
  default = {
    prod    = ""
    dev     = ""
    default = ""
  }
}
