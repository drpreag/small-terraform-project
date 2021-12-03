# Local private zone

resource "aws_route53_zone" "private" {
  name    = "local"
  comment = "PRIVATE zone for ${local.vpc_name}"
  vpc {
    vpc_id = var.vpc.id
  }
}

resource "aws_route53_zone" "public" {
  name    = "aws.scand-it.com"
  comment = "PUBLIC zone for aws.scand-it.com"
  vpc {
    vpc_id = var.vpc.id
  }
}