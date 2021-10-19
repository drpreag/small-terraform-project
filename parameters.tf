# Make only to this file only, do not hardcode any parameter to main.tf
#
# This terraform repository creates:
#
#         VPC with IGW, subnets, route tables, NACLs and security groups
#         Instance IAM role / profile
#         KMS key
#         R53 records
#
#         TBD:
#         Core instance(s) for taking a load
#         Bastion host (one instance in dmz subnet)
#         ALB
#
# Author Predrag Vlajkovic 2021
#

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

# Variables

variable "vpc_name" { default = "stfp" }

variable "aws_region" { default = "eu-west-1" }

variable "vpc_cidr" {
  description = "VPC CIDR range in form: 10.XXX.0.0/16"
  default     = "10.24.0.0/16"
}

# How many subnet per AZ to create
variable "subnets_per_az" { default = 2 }

variable "key_name" { default = "drpreag_2021" }

# Instance types
variable "bastion_instance_type" { default = "t3a.micro" }
variable "lb_instance_type" { default = "t3a.micro" }
variable "core_instance_type" { default = "t3a.micro" }
variable "rds_instance_type" { default = "db.t3.micro" }

# Core autoscaling group
variable "desired_capacity" { default = 1 }
variable "max_size" { default = 1 }
variable "min_size" { default = 1 }

locals {
  second_octet       = split(".", var.vpc_cidr)[1]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}
