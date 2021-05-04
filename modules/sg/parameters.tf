
variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_region" {}
variable "second_octet" {}
variable "main_tags" {}

# Customers IPs to be whitelisted on proxy for port 443
variable "whitelist_ips" {
    type = map
    default = {
        # "drpreag"      = "62.240.26.13/32"
    }
}

# Daon VPC ips to be whitelisted on proxy for port 443
variable "company_ips" {
    type = map
    default = {
        "drpreag"      = "62.240.26.13/32"
    }
}

locals {

  vpc_cidr_block = join (".", ["10", var.second_octet, "0.0/16"] )

  nat_sg_rules = [
    {
        description         = "Salt from VPC"
        port                = 4505
        protocol            = "tcp"
        cidr_blocks         = [ local.vpc_cidr_block ]
    },
    {
        description         = "Salt from VPC"
        port                = 4506
        protocol            = "tcp"
        cidr_blocks         = [ local.vpc_cidr_block ]
    },
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

  proxy_sg_rules = [
  ]

  core_sg_rules = [
    {
        description         = "Https from proxy"
        port                = 443
        protocol            = "tcp"
        security_groups     = [aws_security_group.proxy_sg.id]
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