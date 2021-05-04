# Creates basic VPC with subnets, route tables, NACLs and security groups
# Creates:
#         Bastion host
#         HAProxy instance
#         Core instance
#         S3 bucket with web hosting
#         IAM role

provider "aws" {
  region = var.aws_region
  profile = "drpreag"
}

# Basic stuff
variable "vpc_name"             { default = "dev" }

variable "aws_region"           { default = "eu-west-1" }
variable "vpc_cidr"           {
  description = "VPC main CIDR range in form: 10.XXX.0.0/16"
  default = "10.12.0.0/16"
}

variable "subnet_types"         {
  type = list
  default = [ "dmz", "core", "db" ]
}
# total nunber of core instances will be [core_subnets_per_az] x [core_instances_per_subnet]
variable "core_subnets_per_az"        { default = 1 }
variable "core_instances_per_subnet"  { default = 1 }
variable "availability_zones"   {
  type = list
  default = [ "a", "b", "c", "d" ]
}

variable "key_name"             { default = "drpreag" }

# AMI s
variable "nat_instance_type"    { default = "t3a.micro" }
variable "proxy_instance_type"  { default = "t3a.micro" }
variable "core_instance_type"   { default = "t3a.micro" }

# Tags
variable "main_tags" {
  default = {
    Creator     = "Terraform"
    Project     = "basic_vpc"
  }
}

locals {
  second_octet        = split(".", var.vpc_cidr)[1]
}
