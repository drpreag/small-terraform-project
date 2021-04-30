
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
  nat_sg_rules = [
    # {
    #     description     = "SSH from anywhere"
    #     port            = 22
    #     protocol        = "tcp"
    #     cidr_blocks     = ["0.0.0.0/0"]
    # }
  ]

  proxy_sg_rules = [
    {
        description         = "SSH from NAT"
        port                = 22
        protocol            = "tcp"
        security_groups     = [aws_security_group.nat_sg.id]
    }
  ]

  core_sg_rules = [
    {
        description         = "SSH from NAT"
        port                = 22
        protocol            = "tcp"
        security_groups     = [aws_security_group.nat_sg.id]
    },
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