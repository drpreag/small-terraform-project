variable "vpc" {}

variable "bastion_instance_type" {}

variable "bastion_subnet_id" {}

variable "key_name" {}

variable "aws_region" {}

variable "instance_profile" {}

variable "bastion_sec_group" {}

variable "route53_zone_local" {}

locals {
  image_name_filter="amzl2-base-os-v"
}