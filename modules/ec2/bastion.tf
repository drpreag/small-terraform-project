# BASTION ec2 instance in dmz subnet
# TREBA DA IMAMO DVA INTERFACE-a

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.base_os_image.id
  instance_type = var.bastion_instance_type
  network_interface {
    network_interface_id = var.bastion_eni.id
    device_index         = 0
  }
  key_name                = var.key_name
  iam_instance_profile    = var.instance_profile
  disable_api_termination = false # set to true when done done
  ebs_optimized           = false
  hibernation             = false
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  credit_specification {
    cpu_credits = "standard"
  }
  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname "${local.vpc_name}-bastion"
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    service iptables save
    yum check-update
    EOF
  tags = {
    Name = "${local.vpc_name}-bastion"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = var.bastion_sec_group.id
  network_interface_id = var.bastion_eni.id
}

resource "aws_eip" "bastion_eip" {
  vpc                       = true
  network_interface         = var.bastion_eni.id
  associate_with_private_ip = var.bastion_eni.private_ip
  tags = {
    Name = "${local.vpc_name}-bastion-eip"
  }
}

data "aws_route53_zone" "private" {
  name         = "local"
  private_zone = true
}

resource "aws_route53_record" "bastion_local" {
  zone_id = data.aws_route53_zone.private.id
  name    = "${local.vpc_name}-bastion.local"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.bastion.private_ip]
}

data "aws_route53_zone" "public" {
  name         = "aws.scand-it.com"
  private_zone = true
}

resource "aws_route53_record" "bastion_public" {
  zone_id = data.aws_route53_zone.public.id
  name    = "bastion.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.bastion_eip.public_ip]
}