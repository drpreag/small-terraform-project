# Make changes only to this file, do not hardcode changes to main.tf
#
# Creates:
#         VPC with subnets, route tables, NACLs and security groups
#         Bastion host  (one instance in first dmz subnet)
#         Load balancer instance  (one instance in first dmz subnet)
#         Core instance(s) for taking a load (multiple instances)
#         S3 bucket
#         Instance IAM role
#         KMS key
#         R53 records
#         RDS

provider "aws" {
  region = var.aws_region
  profile = "default"
}

# Basic stuff
variable "vpc_name" { default = "prod" }

variable "aws_region" { default = "eu-west-1" }
variable "vpc_cidr" {
  description = "VPC CIDR range in form: 10.XXX.0.0/16"
  default     = "10.10.0.0/16"
}

variable "subnet_types" {
  type    = list(any)
  default = ["dmz", "core", "db"]
}

variable "core_subnets_per_az" { default = 1 }
variable "core_instances_per_subnet" { default = 1 }
variable "availability_zones" {
  type    = list(any)
  default = ["a", "b", "c"]
}

variable "key_name" { default = "drpreag" }

# AMI's
variable "nat_instance_ami"     { default = "ami-002ebef5ab835ada1" } # custom ami

# Instance types
variable "nat_instance_type" { default = "t3a.micro" }
variable "lb_instance_type" { default = "t3a.micro" }
variable "core_instance_type" { default = "t3a.micro" }

# Tags
variable "main_tags" {
  default = {
    Creator = "Terraform"
    Project = "test_vpc"
  }
}

locals {
  second_octet = split(".", var.vpc_cidr)[1]
}
