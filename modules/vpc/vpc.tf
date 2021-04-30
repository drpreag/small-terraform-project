
# ROUTE TABLES

resource "aws_route_table" "dmz" {
  vpc_id                  = var.vpc_id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = var.vpc_igw.id
  }
  tags = {
    Name                  = "${var.vpc_name}-dmz"
    Vpc                   = var.vpc_name
    Creator               = var.main_tags["Creator"]
  }
}

resource "aws_route_table" "core" {
  vpc_id                  = var.vpc_id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = var.vpc_igw.id
  }
  tags = {
    Name                  = "${var.vpc_name}-core"
    Vpc                   = var.vpc_name
    Creator               = var.main_tags["Creator"]
  }
}

resource "aws_route_table" "db" {
  vpc_id                  = var.vpc_id
  # route {}
  tags = {
    Name                  = "${var.vpc_name}-db"
    Vpc                   = var.vpc_name
    Creator               = var.main_tags["Creator"]
  }
}


# SUBNETS

# DMZ subnet

resource "aws_subnet" "subnet_dmz" {    # create exactly one subnet for dmz
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.vpc_region}${var.availability_zones[0]}"
  cidr_block              = "10.${local.second_octet}.0.0/24"
  tags = {
    Name                  = "${var.vpc_name}-dmz-${var.availability_zones[0]}"
    VpcName               = var.vpc_name
    Creator               = var.main_tags["Creator"]
  }
}

# CORE subnets

resource "aws_subnet" "subnet_core" {
  count                   = var.subnets_per_az
  vpc_id                  = var.vpc_id
  cidr_block              = "10.${local.second_octet}.${count.index+8}.0/24"
  availability_zone       = "${var.vpc_region}${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name                  = "${var.vpc_name}-core-${var.availability_zones[count.index]}"
    VpcName               = var.vpc_name
    Creator               = "Terraform"
  }
}

# DB subnet

resource "aws_subnet" "subnet_db" {     # create exactly 2 db subnet requeired by DB subnet group resource
  count                   = 2
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.vpc_region}${var.availability_zones[count.index]}"
  cidr_block              = "10.${local.second_octet}.${16+count.index}.0/24"
  tags = {
    Name                  = "${var.vpc_name}-db-${var.availability_zones[count.index]}"
    VpcName               = var.vpc_name
    Creator               = var.main_tags["Creator"]
  }
}


# SUBNET ASSOCIATIONS to route tables

resource "aws_route_table_association" "dmz" {
  subnet_id         = aws_subnet.subnet_dmz.id
  route_table_id    = aws_route_table.dmz.id
  depends_on        = [var.nat_eni]
}

resource "aws_route_table_association" "core" {
  count             = var.subnets_per_az
  subnet_id         = aws_subnet.subnet_core[count.index].id
  route_table_id    = aws_route_table.core.id
  depends_on        = [var.nat_eni]
}

resource "aws_route_table_association" "db" {
  count             = 2
  subnet_id         = aws_subnet.subnet_db[count.index].id
  route_table_id    = aws_route_table.db.id
  depends_on        = [var.nat_eni]
}


# NACL's

resource "aws_network_acl" "dmz" {
  vpc_id            = var.vpc_id
  subnet_ids        = [ aws_subnet.subnet_dmz.id ]
  ingress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }
  egress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }
  tags = {
    Name            = "${var.vpc_name}-dmz"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
}

resource "aws_network_acl" "core" {
  vpc_id            = var.vpc_id
  subnet_ids        = aws_subnet.subnet_core[*].id
  ingress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }
  egress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }
  tags = {
    Name            = "${var.vpc_name}-core"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
}

resource "aws_network_acl" "db" {
  vpc_id            = var.vpc_id
  subnet_ids        = aws_subnet.subnet_db[*].id
  ingress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      =  var.vpc_cidr
    from_port       = 0
    to_port         = "65535"
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = "65535"
  }
  tags = {
    Name            = "${var.vpc_name}-db"
    Vpc             = var.vpc_name
    Creator         = var.main_tags.Creator
  }
}
