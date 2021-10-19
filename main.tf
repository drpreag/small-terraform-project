# VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  vpc_region         = var.aws_region
  subnets_per_az     = var.subnets_per_az
  availability_zones = local.availability_zones
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


# ROUTE 53
module "route53" {
  source = "./modules/route53"
  vpc    = module.vpc.vpc
}


# EC2
module "ec2" {
  source                = "./modules/ec2"
  vpc                   = module.vpc.vpc
  bastion_instance_type = var.bastion_instance_type
  bastion_subnet_id     = module.vpc.dmz_subnets_list[0]
  bastion_sec_group     = module.sg.bastion_sec_group
  core_instance_type    = var.core_instance_type
  core_subnets_list     = module.vpc.core_subnets_list
  core_sec_group        = module.sg.core_sec_group
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  key_name              = var.key_name
  instance_profile      = module.iam.instance_profile
  #route53_private_zone  = module.route53.route53_private_zone
}
