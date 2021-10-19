variable "vpc" {}

variable "db_sec_group" {}

variable "db_subnets_list" {}

variable "rds_instance_type" {}

locals {
    vpc_name  = var.vpc.tags["Name"]
}
