variable "vpc" {}

variable "company_ips" {}

locals {
  vpc_name  = var.vpc.tags["Name"]
}