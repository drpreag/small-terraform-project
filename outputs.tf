output "vpc" {
  value = module.vpc.vpc.tags["Name"]
}

output "bastion_ec2_instance" {
  value = module.ec2.bastion.id
}

# output "rds_instance" {
#   value = module.rds.rds_instance.id
# }