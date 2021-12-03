variable "vpc" {}

locals {
  vpc_name = var.vpc.tags["Name"]
}