
# Call VPC module to get vpc igw, route tables, subnets, ACLs, associations
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
  source       = "./modules/sg"
  vpc_id       = module.vpc.vpc.id
  vpc_name     = var.vpc_name
  second_octet = local.second_octet
  depends_on = [
    module.vpc
  ]
}


# IAM
module "iam" {
  source     = "./modules/iam"
  vpc_name   = var.vpc_name
  aws_region = var.aws_region
}
