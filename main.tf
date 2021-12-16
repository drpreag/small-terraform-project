# VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  subnets_per_az     = var.subnets_per_az
  availability_zones = local.availability_zones
}

# SG
module "sg" {
  source      = "./modules/sg"
  vpc         = module.vpc.vpc
  company_ips = var.company_ips
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
  bastion_eni           = module.vpc.bastion_eni
  bastion_instance_type = var.bastion_instance_type
  bastion_sec_group     = module.sg.bastion_sec_group
  dmz_subnets_list      = module.vpc.dmz_subnets_list
  core_instance_type    = var.core_instance_type
  core_sec_group        = module.sg.core_sec_group
  core_subnets_list     = module.vpc.core_subnets_list
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  key_name              = var.key_name
  instance_profile      = module.iam.instance_profile
  depends_on            = [module.route53]
}

