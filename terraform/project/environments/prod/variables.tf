variable "env" {
  type = string
}

variable "vpc_id" {
  type = string

  default = "xxx"
}

variable "vpc_public_subnet_id" {
  type = string

  default = "xxx"
}

variable "vpc_private_subnet_ids" {
  type = list(string)

  default = ["xxx", "yyy", "zzz"]
}
