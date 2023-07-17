provider "aws" {
  region  = "ap-northeast-1"
  # NOTE: 任意のプロファイルを指定
  profile = "xxx"

  default_tags {
    tags = {
      env       = var.env
      Service   = "prefix"
      terraform = true
    }
  }
}

# tfstateの状態をS3で管理
terraform {
  required_version = ">= 1.4.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }

  backend "s3" {
    # NOTE: 任意のプロファイルを指定
    profile = "xxx"
    bucket  = "prefix-xxx-prod-terraform-state"
    region  = "ap-northeast-1"
    key     = "terraform.tfstate"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
