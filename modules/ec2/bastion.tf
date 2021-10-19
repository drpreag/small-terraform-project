# BASTION ec2 instance in dmz subnet

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.base_os_image.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.bastion_subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true
  source_dest_check           = true
  vpc_security_group_ids      = [ var.bastion_sec_group.id ]
  disable_api_termination     = false  # set to true when done done
  ebs_optimized               = false
  hibernation                 = false
  root_block_device {
    volume_size               = 8
    volume_type               = "gp2"
    delete_on_termination     = true
  }
  credit_specification {
    cpu_credits               = "standard"
  }
  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname "${local.vpc_name}-bastion"
    yum check-update
    EOF
  tags = {
    Name                      = "${local.vpc_name}-bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc                         = true
  instance                    = aws_instance.bastion.id
  tags = {
    Name                      = "${local.vpc_name}-bastion-eip"
  }
}

data "aws_route53_zone" "private" {
  name         = "local"
  private_zone = true
}

resource "aws_route53_record" "bastion_local" {
  zone_id                     = data.aws_route53_zone.private.id
  name                        = "${local.vpc_name}-bastion.local"
  type                        = "A"
  ttl                         = "300"
  records = [ aws_instance.bastion.private_ip ]
}
