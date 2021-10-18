# basic terraform project settings

terraform {
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