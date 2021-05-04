# VPC

resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name                = var.vpc_name
    Creator             = var.main_tags["Creator"]
  }
  provisioner "local-exec" {
    command = "echo \"VPC ${self.id}\""
  }
}


# Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id        = aws_vpc.vpc.id
  tags = {
    Name        = "${var.vpc_name}-igw"
    Vpc         = var.vpc_name
    Creator     = var.main_tags["Creator"]
  }
  provisioner "local-exec" {
    command = "echo \"IGW ${self.id}\""
  }
}

# Route tables, subnets, ACLs, associations
module "vpc" {
  source          = "./modules/vpc"
  vpc_id          = aws_vpc.vpc.id
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  nat_eni         = aws_network_interface.nat_eni
  vpc_igw         = aws_internet_gateway.igw
  vpc_region      = var.aws_region
  subnet_types    = var.subnet_types
  core_subnets_per_az   = var.core_subnets_per_az
  availability_zones    = var.availability_zones
  main_tags       = var.main_tags
}

# Security groups
module "sg" {
  source        = "./modules/sg"
  vpc_id        = aws_vpc.vpc.id
  vpc_name      = var.vpc_name
  vpc_region    = var.aws_region
  second_octet  = local.second_octet
  main_tags     = var.main_tags
}


# Primary ENI for nat instance
resource "aws_network_interface" "nat_eni" {
  subnet_id         = module.vpc.dmz_subnet[0].id       # place it in subnet_dmz_a, first zone
  security_groups   = [module.sg.nat_sec_group.id]
  source_dest_check = false
  tags = {
    Name            = "${var.vpc_name}-nat-primary"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
  provisioner "local-exec" {
    command = "echo \"NAT ENI interface ${self.id}\""
  }
}
resource "aws_eip" "nat_primary" {
  vpc                       = true
  network_interface         = aws_network_interface.nat_eni.id
  associate_with_private_ip = aws_network_interface.nat_eni.private_ip
}


# Primary ENI for proxy instance
resource "aws_network_interface" "proxy_eni" {
  subnet_id       = module.vpc.dmz_subnet[0].id      # place it in subnet_dmz_a, first zone
  security_groups = [module.sg.proxy_sec_group.id]
  tags = {
    Name          = "${var.vpc_name}-proxy-primary"
    Vpc           = var.vpc_name
    Creator       = var.main_tags["Creator"]
  }
  provisioner "local-exec" {
    command = "echo \"PROXY ENI interface ${self.id}\""
  }
}
resource "aws_eip" "proxy_primary" {
  vpc                       = true
  network_interface         = aws_network_interface.proxy_eni.id
  associate_with_private_ip = aws_network_interface.proxy_eni.private_ip
}


# VPC endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id        = aws_vpc.vpc.id
  service_name  = join ("", ["com.amazonaws.", var.aws_region, ".s3"])
  tags = {
    Name        = "${var.vpc_name}-endpoint"
    Vpc         = var.vpc_name
    Creator     = var.main_tags["Creator"]
  }
  provisioner "local-exec" {
    command = "echo \"S3 VPC endpoint ${self.id}\""
  }
}

# VPC endpoint route table Associations
resource "aws_vpc_endpoint_route_table_association" "dmz_s3" {
  vpc_endpoint_id   = aws_vpc_endpoint.s3.id
  route_table_id    = module.vpc.route_table_dmz.id
  depends_on        = [aws_network_interface.nat_eni]
}
resource "aws_vpc_endpoint_route_table_association" "core_s3" {
  vpc_endpoint_id   = aws_vpc_endpoint.s3.id
  route_table_id    = module.vpc.route_table_core.id
  depends_on        = [aws_network_interface.nat_eni]
}


# Get latest AMI image
module "ami" {
  source        = "./modules/ami"
}

# NAT ec2 instance
resource "aws_instance" "nat_instance" {
  #ami                   = var.nat_ami
  ami                   = module.ami.latest_ami.id
  instance_type         = var.nat_instance_type
  availability_zone     = "${var.aws_region}a"
  key_name              = var.key_name
  iam_instance_profile  = module.iam.instance_profile
  network_interface {
    network_interface_id  = aws_network_interface.nat_eni.id
    device_index          = 0
  }
  tags = {
    Name            = "${var.vpc_name}-nat"
    Role            = "${var.vpc_name}-nat"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
  depends_on        = [aws_network_interface.nat_eni]
  provisioner "local-exec" {
    command = "echo \"NAT instance ${self.id}\""
  }
}

# Proxy ec2 instance
resource "aws_instance" "proxy_instance" {
  #ami                   = var.proxy_ami
  ami                   = module.ami.latest_ami.id
  instance_type         = var.proxy_instance_type
  availability_zone     = "${var.aws_region}a"
  key_name              = var.key_name
  iam_instance_profile  = module.iam.instance_profile
  network_interface {
    network_interface_id  = aws_network_interface.proxy_eni.id
    device_index          = 0
  }
  tags = {
    Name            = "${var.vpc_name}-proxy"
    Role            = "${var.vpc_name}-proxy"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
  depends_on        = [aws_network_interface.proxy_eni]
  provisioner "local-exec" {
    command = "echo \"Proxy instance ${self.id}\""
  }
}


# S3
module "s3" {
  source        = "./modules/s3"
  vpc_name      = var.vpc_name
  main_tags     = var.main_tags
}


# IAM
module "iam" {
  source        = "./modules/iam"
  vpc_name      = var.vpc_name
  aws_region    = var.aws_region
  s3_bucket     = module.s3.s3_bucket_arn.arn
  main_tags     = var.main_tags
}

# Core instance
resource "aws_instance" "core_instance" {
  count                 = var.core_subnets_per_az * var.core_instances_per_subnet
  ami                   = module.ami.latest_ami.id
# ami                   = var.core_ami
  instance_type         = var.core_instance_type
  availability_zone     = "${var.aws_region}${var.availability_zones[count.index]}"
  key_name              = var.key_name
  iam_instance_profile  = module.iam.instance_profile
  subnet_id             = module.vpc.core_subnets_list[count.index]
  vpc_security_group_ids = [module.sg.core_sec_group.id]
  tags = {
    Name            = "${var.vpc_name}-core-${count.index+1}${var.availability_zones[count.index]}"
    Role            = "${var.vpc_name}-core"
    Vpc             = var.vpc_name
    Creator         = var.main_tags["Creator"]
  }
}