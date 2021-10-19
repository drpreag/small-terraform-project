
resource "aws_kms_key" "main_key" {
  description             = "${local.vpc_name}"
  deletion_window_in_days = 7
  policy                  = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                    },
                    "Action": "kms:*",
                    "Resource": "*"
                }
            ]
        })
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.vpc_name}"
  target_key_id = aws_kms_key.main_key.id
}

data "aws_caller_identity" "current" {}
