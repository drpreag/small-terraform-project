
data "aws_ami" "base_os" {
  most_recent      = true
  owners           = ["self"]

  filter {
    #name   = "tag:ami_name"
    name   = "tag:Name"
    values = ["base_os*"]
  }

}
