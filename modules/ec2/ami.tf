# get base ami image

data "aws_ami" "base_os_image" {
  most_recent                 = true
  owners                      = ["self"]
  filter {
    name                      = "tag:Name"
    values                    = ["${local.image_name_filter}*"]
  }
}