variable "vpc_name" {}
variable "aws_region" {}
variable "s3_bucket" {}
variable "main_tags" {}

locals {
    # cw_agent_server_policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    # daon_get_metrics_arn = "arn:aws:iam::675147122923:policy/DaonGetMetrics"
    # daon_software_ro_arn = "arn:aws:iam::675147122923:policy/DaonSoftwareRO"
}
