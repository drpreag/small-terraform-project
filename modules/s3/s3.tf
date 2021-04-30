# S3 bucket

resource "aws_s3_bucket" "vpc_bucket" {
  bucket = "${var.vpc_name}"
  acl    = "private"
  # policy = file("policy.json")
  force_destroy = true

  versioning {
    enabled = true
   }
  website {
    index_document = "index.html"
    error_document = "error.html"

#     routing_rules = <<EOF
# [{
#     "Condition": {
#         "KeyPrefixEquals": "docs/"
#     },
#     "Redirect": {
#         "ReplaceKeyPrefixWith": "documents/"
#     }
# }]
# EOF
  }
  tags = {
    Name      = "${var.vpc_name}"
    Vpc       = var.vpc_name
    Creator   = var.main_tags["Creator"]
  }
}
