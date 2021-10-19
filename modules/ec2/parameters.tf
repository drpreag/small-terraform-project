variable "vpc" {}

#variable "availability_zones" {}

variable "bastion_instance_type" {}
variable "bastion_subnet_id" {}
variable "bastion_sec_group" {}

variable "core_instance_type" {}
variable "core_subnets_list" {}
variable "core_sec_group" {}
variable "desired_capacity" {}
variable "max_size"         {}
variable "min_size"         {}
variable "key_name" {}

#variable "aws_region" {}

variable "instance_profile" {}

#variable "route53_private_zone" {}

locals {

  image_name_filter="amzl2-base-os-v"

  vpc_name  = var.vpc.tags["Name"]

}