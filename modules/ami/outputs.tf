
# output "latest_ami" {
#   value = data.aws_ami.latest
# }


output "latest_ami" {
  value = data.aws_ami.base_os
}