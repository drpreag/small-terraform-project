
# BASTION ec2 instance in dmz subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.base_os_image.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.bastion_subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true
  source_dest_check           = false
  security_groups             = [ var.bastion_sec_group.id ]
  disable_api_termination     = false  # set to true when done done
  ebs_optimized               = false
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
    hostnamectl set-hostname "${var.vpc.tags["Name"]}-bastion"
    yum check-update
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    EOF
  tags = {
    Name                      = "${var.vpc.tags["Name"]}-bastion"
  }
  provisioner "local-exec" {
    command                   = "echo \"Bastion instance ${self.id}\""
  }
}

resource "aws_eip" "bastion_eip" {
  vpc                         = true
  instance                    = aws_instance.bastion.id
  tags = {
    Name                      = "${var.vpc.tags["Name"]}-bastion-eip"
  }
}


# R53 records

resource "aws_route53_record" "bastion_local" {
  zone_id                     = var.route53_zone_local.id
  name                        = "bastion.local"
  type                        = "A"
  ttl                         = "300"
  records = [ aws_instance.bastion.private_ip ]
}


# get base ami image
data "aws_ami" "base_os_image" {
  most_recent                 = true
  owners                      = ["self"]
  filter {
    name                      = "tag:Name"
    values                    = ["${local.image_name_filter}*"]
  }
}
