
# Zones

resource "aws_route53_zone" "local" {
  name    = "local"
  comment = "PRIVATE zone for ${var.vpc_name}"

  vpc {
    vpc_id = var.vpc_id
  }
}

# Records

resource "aws_route53_record" "local_any_local" {
  zone_id = aws_route53_zone.local.id
  name    = "local.any.local"
  type    = "A"
  ttl     = "300"
  records = ["127.0.0.1"]
}
