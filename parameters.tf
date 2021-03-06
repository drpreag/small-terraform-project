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
#         ALB
#
# Author Predrag Vlajkovic 2021
#

variable "vpc_name" { default = "stfp" }

variable "aws_region" { default = "eu-west-1" }

variable "vpc_cidr" {
  description = "VPC CIDR range in form: 10.XXX.0.0/16"
  default     = "10.10.0.0/16"
}

# How many subnet per AZ to create
variable "subnets_per_az" { default = 2 }

variable "key_name" { default = "drpreag_2021" }

# Instance types
variable "bastion_instance_type" { default = "t3a.micro" }
variable "core_instance_type" { default = "t3a.micro" }
variable "rds_instance_type" { default = "db.t3.micro" }

# Core autoscaling group
variable "desired_capacity" { default = 0 }
variable "max_size" { default = 0 }
variable "min_size" { default = 0 }

# for whitelisting IPs on SG for SSH on bastion host
variable "company_ips" {
  type = map(any)
  default = {
    "Predrag home" = "46.235.100.0/24"
  }
}

locals {
  second_octet       = split(".", var.vpc_cidr)[1]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}
