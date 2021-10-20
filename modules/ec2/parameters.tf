variable "vpc" {}

variable "bastion_eni" {}
variable "bastion_instance_type" {}
variable "bastion_sec_group" {}
variable "dmz_subnets_list" {}

variable "core_instance_type" {}
variable "core_subnets_list" {}
variable "core_sec_group" {}

variable "desired_capacity" {}
variable "max_size"         {}
variable "min_size"         {}
variable "key_name" {}

variable "instance_profile" {}

locals {

  image_name_filter="amzl2-base-os-v"

  vpc_name  = var.vpc.tags["Name"]

}