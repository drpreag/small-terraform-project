
data "aws_ami" "base_os" {
  #executable_users = ["self"]
  most_recent      = true
  # name_regex       = "^base_os_v\\d{3}"
  owners           = ["self"]

  filter {
    #name   = "tag:ami_name"
    name   = "tag:Name"
    values = ["base_os*"]
  }

}

# data "aws_ami_ids" "base_os" {
#   owners = ["self"]
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["base_os*"]
#   }
# }