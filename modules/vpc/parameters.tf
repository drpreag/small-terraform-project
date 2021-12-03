variable "vpc_name" {}

variable "vpc_cidr" {}

variable "subnets_per_az" { default = 1 } # for core subnet subnet only, dmz and db are hardcoded to 1

variable "availability_zones" {}

locals {
  second_octet = split(".", var.vpc_cidr)[1]
}

