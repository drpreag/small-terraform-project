# VPC

module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  vpc_region         = var.aws_region
  subnets_per_az     = var.subnets_per_az
  availability_zones = var.availability_zones
}


# Security groups
module "sg" {
  source = "./modules/sg"
  vpc    = module.vpc.vpc
}


# IAM
module "iam" {
  source     = "./modules/iam"
  vpc        = module.vpc.vpc
  aws_region = var.aws_region
}


# EC2
module "ec2" {
  source                = "./modules/ec2"
  vpc                   = module.vpc.vpc
  bastion_instance_type = var.bastion_instance_type
  bastion_subnet_id     = module.vpc.dmz_subnet[0]
  key_name              = var.key_name
  aws_region            = var.aws_region
  instance_profile      = module.iam.instance_profile
  bastion_sec_group     = module.sg.bastion_sec_group
  route53_zone_local    = module.route53.route53_zone_local
}


# ROUTE 53
module "route53" {
  source = "./modules/route53"
  vpc    = module.vpc.vpc
}
