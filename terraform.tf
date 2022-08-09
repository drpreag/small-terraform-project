# basic terraform project settings

provider "aws" {
  region  = var.aws_region
  profile = "default"
  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "DrPreAG"
      Creator     = "infrastructure/terraform"
      Project     = "small-terraform-project"
      Vpc         = "${var.vpc_name}"
    }
  }
}

terraform {
  required_version = ">= 1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
  backend "s3" {
    bucket = "imosoft-terraform-state-bucket"
    region = "eu-west-1"
    key    = "small-terraform-project/env-dev.tfstate"
  }
}
