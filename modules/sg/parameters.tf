variable "vpc_id" {}

variable "vpc_name" {}

#variable "vpc_region" {}

variable "second_octet" {}

# IPs to be whitelisted on lb for port 443
variable "company_ips" {
    type = map
    default = {
        "drpreag"      = "46.235.100.0/24"
    }
}

locals {

  vpc_cidr_block = join (".", ["10", var.second_octet, "0.0/16"] )

  nat_sg_rules = [
    {
        description         = "HTTP from VPC"
        port                = 80
        protocol            = "tcp"
        cidr_blocks         = [ local.vpc_cidr_block ]
    },
    {
        description         = "HTTPS from VPC"
        port                = 443
        protocol            = "tcp"
        cidr_blocks         = [ local.vpc_cidr_block ]
    }
  ]

  lb_sg_rules = [
  ]

  core_sg_rules = [
    {
        description         = "Https from lb"
        port                = 443
        protocol            = "tcp"
        security_groups     = [aws_security_group.lb_sg.id]
    }
  ]

  db_sg_rules = [
    {
        description         = "MySQL from core"
        port                = 3306
        protocol            = "tcp"
        security_groups     = [aws_security_group.core_sg.id]
    }
  ]
}