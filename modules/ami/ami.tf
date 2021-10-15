
data "aws_ami" "base_os" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "tag:Name"
    values = ["${local.image_name_filter}*"]
  }

}
