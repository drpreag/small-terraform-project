
# NAT sg
resource "aws_security_group" "nat_sg" {
  name        = "${var.vpc_name}-nat"
  description = "NAT security group"
  vpc_id      = var.vpc_id

  dynamic ingress {
    for_each = local.nat_sg_rules
      content {
        description      = ingress.value.description
        from_port        = ingress.value.port
        to_port          = ingress.value.port
        protocol         = ingress.value.protocol
        cidr_blocks      = ingress.value.cidr_blocks
      }
  }
  dynamic ingress {
    for_each = var.company_ips
    content {
      description      = "SSH from ${ingress.key}"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [ ingress.value ]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name       = "${var.vpc_name}-nat"
  }
}


# LB sg
resource "aws_security_group" "lb_sg" {
  name        = "${var.vpc_name}-lb"
  description = "LB / HTTPS security group"
  vpc_id      = var.vpc_id
  dynamic ingress {
    for_each = local.lb_sg_rules
      content {
        description      = ingress.value.description
        from_port        = ingress.value.port
        to_port          = ingress.value.port
        protocol         = ingress.value.protocol
        security_groups  = ingress.value.security_groups
      }
  }
  ingress {
    description         = "All from lb"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    self                = true
  }
  ingress {
    description         = "All from nat"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.nat_sg.id ]
  }

  ingress {
    description         = "HTTP from anywhere"
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }
  ingress {
    description         = "HTTPS from anywhere"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.vpc_name}-lb"
    Creator     = var.main_tags["Creator"]
  }
}

# Core sg
resource "aws_security_group" "core_sg" {
  name        = "${var.vpc_name}-core"
  description = "Core security group"
  vpc_id      = var.vpc_id
  dynamic ingress {
    for_each = local.core_sg_rules
      content {
        description      = ingress.value.description
        from_port        = ingress.value.port
        to_port          = ingress.value.port
        protocol         = ingress.value.protocol
        security_groups  = ingress.value.security_groups
      }
  }
  ingress {
    description         = "All from core"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    self                = true
  }
  ingress {
    description         = "All from nat"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.nat_sg.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.vpc_name}-core"
    Creator     = var.main_tags["Creator"]
  }
}


# DB sg
resource "aws_security_group" "db_sg" {
  name        = "${var.vpc_name}-db"
  description = "DB security group"
  vpc_id      = var.vpc_id

  dynamic ingress {
    for_each = local.db_sg_rules
      content {
        description      = ingress.value.description
        from_port        = ingress.value.port
        to_port          = ingress.value.port
        protocol         = ingress.value.protocol
        security_groups  = ingress.value.security_groups
      }
  }
  ingress {
    description         = "All from db"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    self                = true
  }
  ingress {
    description         = "All from nat"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.nat_sg.id ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ local.vpc_cidr_block ]
  }

  tags = {
    Name        = "${var.vpc_name}-db"
    Creator     = var.main_tags["Creator"]
  }
}
