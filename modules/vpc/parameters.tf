variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "nat_eni" {}
variable "vpc_igw" {}
variable "vpc_region" {}
variable "subnet_types" {}
variable "subnets_per_az" { default = 1 } # for core subnet subnet only, dmz and db are hardcoded to 1
variable "main_tags" {}
variable "availability_zones" {}

locals {
  second_octet      = split(".", var.vpc_cidr)[1]
}

