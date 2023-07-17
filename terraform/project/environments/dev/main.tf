provider "aws" {
  region  = "ap-northeast-1"
  profile = "prefix-xxx-sandbox"

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
    profile        = "prefix-xxx-sandbox"
    bucket         = "prefix-xxx-dev-terraform-state-lock"
    region         = "ap-northeast-1"
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "prefix-xxx-dev-terraform-state-lock"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
