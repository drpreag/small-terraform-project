
# VPC

resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  enable_dns_support      = true
  enable_dns_hostnames    = true
  tags = {
    Name    = var.vpc_name
  }
  provisioner "local-exec" {
    command = "echo \"VPC ${self.id}\""
  }
}


# IGW

resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    Name                  = "${var.vpc_name}-igw"
  }
}


# SUBNETS

# DMZ subnet
resource "aws_subnet" "subnet_dmz" {
  count                   = var.subnets_per_az
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${local.second_octet}.${count.index}.0/24"
  availability_zone       = "${var.availability_zones[count.index]}"
  tags = {
    Name                  = "${var.vpc_name}-dmz-${var.availability_zones[count.index]}"
  }
}

# CORE subnets
resource "aws_subnet" "subnet_core" {
  count                   = var.subnets_per_az
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${local.second_octet}.${count.index+8}.0/24"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name                  = "${var.vpc_name}-core-${var.availability_zones[count.index]}"
  }
}

# DB subnet
resource "aws_subnet" "subnet_db" {
  count                   = var.subnets_per_az
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${local.second_octet}.${count.index+16}.0/24"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name                  = "${var.vpc_name}-db-${var.availability_zones[count.index]}"
  }
}

# Primary ENI for bastion/nat instance
resource "aws_network_interface" "bastion_eni" {
  # deploy it in first AZ, dmz subnet
  subnet_id           = aws_subnet.subnet_dmz[0].id
  source_dest_check   = false
  provisioner "local-exec" {
    command           = "echo \"Bastion ENI interface ${self.id}\""
  }
}

# ROUTE TABLES

resource "aws_route_table" "dmz" {
  vpc_id                  = aws_vpc.vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.igw.id
  }
  tags = {
    Name                  = "${var.vpc_name}-dmz"
  }
}

resource "aws_route_table" "core" {
  vpc_id                  = aws_vpc.vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.bastion_eni.id
  }
  tags = {
    Name                  = "${var.vpc_name}-core"
  }
}

resource "aws_route_table" "db" {
  vpc_id                  = aws_vpc.vpc.id
  # route {
  #   cidr_block            = var.vpc_cidr
  #   network_interface_id  = aws_network_interface.bastion_eni.id
  # }
  tags = {
    Name                  = "${var.vpc_name}-db"
  }
}


# SUBNET ASSOCIATIONS to route tables

resource "aws_route_table_association" "dmz" {
  count                   = var.subnets_per_az
  subnet_id               = aws_subnet.subnet_dmz[count.index].id
  route_table_id          = aws_route_table.dmz.id
}

resource "aws_route_table_association" "core" {
  count                   = var.subnets_per_az
  subnet_id               = aws_subnet.subnet_core[count.index].id
  route_table_id          = aws_route_table.core.id
}

resource "aws_route_table_association" "db" {
  count                   = var.subnets_per_az
  subnet_id               = aws_subnet.subnet_db[count.index].id
  route_table_id          = aws_route_table.db.id
}


# NACL's

resource "aws_network_acl" "dmz" {
  vpc_id            = aws_vpc.vpc.id
  subnet_ids        = aws_subnet.subnet_dmz[*].id
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
  }
}

resource "aws_network_acl" "core" {
  vpc_id            = aws_vpc.vpc.id
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
  }
}

resource "aws_network_acl" "db" {
  vpc_id            = aws_vpc.vpc.id
  subnet_ids        = aws_subnet.subnet_db[*].id

  ingress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "10.${local.second_octet}.8.0/21"
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
  }
}
