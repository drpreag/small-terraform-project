# Creates basic VPC with subnets, route tables, NACLs and security groups
# Creates:
#         Bastion host
#         HAProxy instance
#         S3 bucket with web hosting
#         IAM role

provider "aws" {
  region = var.aws_region
  profile = "drpreag"
}

# Basic stuff
variable "vpc_name"             { default = "drpreag.in.rs" }

variable "aws_region"           { default = "eu-west-1" }
variable "vpc_cidr"           {
  description = "VPC main CIDR range in form: 10.XXX.0.0/16"
  default = "10.11.0.0/16"
}

variable "subnet_types"         {
  type = list
  default = [ "dmz", "core", "db" ]
}
variable "subnets_per_az"       { default = 1 }
variable "availability_zones"   {
  type = list
  default = [ "a", "b" ]
}

variable "key_name"             { default = "drpreag" }

# AMI s
variable "nat_ami"              { default = "ami-03db011e0177dfb83" }
variable "nat_instance_type"    { default = "t3a.micro" }
variable "proxy_ami"            { default = "ami-03db011e0177dfb83" }
variable "proxy_instance_type"  { default = "t3a.micro" }

# Tags
variable "main_tags" {
  default = {
    Creator     = "Terraform"
    Project     = "drpreag.in.rs"
  }
}

locals {
  second_octet        = split(".", var.vpc_cidr)[1]
}
