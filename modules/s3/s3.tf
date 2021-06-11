# S3 bucket

resource "aws_s3_bucket" "vpc_bucket" {
  bucket = "${var.vpc_name}-fjdhgute-vpc"
  acl    = "public-read"
  # policy = file("policy.json")
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  tags = {
    Name      = "${var.vpc_name}"
    Vpc       = var.vpc_name
    Creator   = var.main_tags["Creator"]
  }
}
