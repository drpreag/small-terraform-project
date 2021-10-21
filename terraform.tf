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
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
  }
  backend "s3" {
    bucket = "imosoft-terraform-state"
    region = "eu-west-1"
    key    = "small-terraform-project.tfstate"
  }
}
