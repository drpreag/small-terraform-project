# Bastion sg

resource "aws_security_group" "bastion_sg" {
  name        = "${local.vpc_name}-bastion"
  description = "Bastion security group"
  vpc_id      = var.vpc.id

  dynamic ingress {
    for_each = local.bastion_sg_rules
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
    Name       = "${local.vpc_name}-bastion"
  }
}


# LB sg

resource "aws_security_group" "lb_sg" {
  name        = "${local.vpc_name}-lb"
  description = "LB / HTTPS security group"
  vpc_id      = var.vpc.id
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
    description         = "All from bastion"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.bastion_sg.id ]
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
    Name        = "${local.vpc_name}-lb"
  }
}

# Core sg

resource "aws_security_group" "core_sg" {
  name        = "${local.vpc_name}-core"
  description = "Core security group"
  vpc_id      = var.vpc.id
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
    description         = "All from bastion"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.bastion_sg.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${local.vpc_name}-core"
  }
}


# DB sg

resource "aws_security_group" "db_sg" {
  name        = "${local.vpc_name}-db"
  description = "DB security group"
  vpc_id      = var.vpc.id

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
    description         = "All from core"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    security_groups     = [ aws_security_group.core_sg.id ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ var.vpc.cidr_block ]
  }

  tags = {
    Name        = "${local.vpc_name}-db"
  }
}
