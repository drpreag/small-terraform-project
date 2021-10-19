# # CORE ec2 instance in core subnet

# resource "aws_instance" "core_0" {
#   ami                         = data.aws_ami.base_os_image.id
#   instance_type               = var.core_instance_type
#   subnet_id                   = var.core_subnet_id
#   key_name                    = var.key_name
#   iam_instance_profile        = var.instance_profile
#   associate_public_ip_address = true
#   source_dest_check           = false
#   vpc_security_group_ids      = [ var.core_sec_group.id ]
#   disable_api_termination     = false  # set to true when done done
#   ebs_optimized               = false
#   hibernation                 = false
#   root_block_device {
#     volume_size               = 8
#     volume_type               = "gp2"
#     delete_on_termination     = true
#   }
#   credit_specification {
#     cpu_credits               = "standard"
#   }
#   user_data = <<-EOF
#     #!/bin/bash
#     hostnamectl set-hostname "${local.vpc_name}-core-0"
#     yum check-update
#     EOF
#   tags = {
#     Name                      = "${local.vpc_name}-core"
#   }
# }

# resource "aws_route53_record" "core_0_local" {
#   zone_id                     = var.route53_zone_local.id
#   name                        = "core-0.local"
#   type                        = "A"
#   ttl                         = "300"
#   records = [ aws_instance.core_0.private_ip ]
# }
