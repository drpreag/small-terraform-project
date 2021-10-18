variable "vpc" {}

# IPs to be whitelisted on lb for port 443
# TBD move all SG rules to main/parameters.tf, so all changable things be on one place
# not inside a module

variable "company_ips" {
    type = map
    default = {
        "drpreag"      = "46.235.100.0/24"
    }
}

locals {

  vpc_name  = var.vpc.tags["Name"]

  bastion_sg_rules = [
    {
        description         = "SSH"
        port                = 22
        protocol            = "tcp"
        cidr_blocks         = [ var.vpc.cidr_block ]
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