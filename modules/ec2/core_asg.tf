# CORE instances in auto scale group

resource "aws_autoscaling_group" "core" {
  vpc_zone_identifier       = var.core_subnets_list
  name                      = "core"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = false
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.core.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }
  initial_lifecycle_hook {
    name                    = "lifecycle-launching"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    # notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    # role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }
  initial_lifecycle_hook {
    name                    = "lifecycle-terminating"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    # notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    # role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }
  tag {
    key                 = "asg:hostname_pattern"
    value               = "${local.vpc_name}-core-#instanceid.local@${data.aws_route53_zone.private.id}"
    propagate_at_launch = true
  }
  # depends_on = [module.autoscale_dns]
}

resource "aws_launch_template" "core" {
  name_prefix   = "${local.vpc_name}-core-"
  image_id      = data.aws_ami.base_os_image.id
  instance_type = var.core_instance_type
  iam_instance_profile {
    name = var.instance_profile
  }
  disable_api_termination              = false # on done done set to true
  ebs_optimized                        = false
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids               = [var.core_sec_group.id]
  key_name                             = var.key_name
  credit_specification {
    cpu_credits = "standard"
  }
  user_data = base64encode(data.template_file.core.template)
}

data "template_file" "core" {
  template = <<-EOF
    #!/bin/bash
    set -e
    export AVAILABILITY_ZONE=$(curl -sLf http://169.254.169.254/latest/meta-data/placement/availability-zone)
    export INSTANCE_ID=$(curl -sLf http://169.254.169.254/latest/meta-data/instance-id)
    hostnamectl set-hostname "${local.vpc_name}-core-$INSTANCE_ID"
  EOF
}

# module "autoscale_dns" {
#   source                              = "meltwater/asg-dns-handler/aws"
#   version                             = "2.1.7"
#   autoscale_route53zone_arn           = data.aws_route53_zone.private.id
#   vpc_name                            = local.vpc_name
#   autoscale_handler_unique_identifier = "core-asg"
# }
