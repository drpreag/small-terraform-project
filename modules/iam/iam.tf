
# IAM role

resource "aws_iam_role" "service_role" {
  name = var.vpc.tags["Name"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  # inline_policy {
  #   name = "s3_access"
  #   policy = jsonencode({
  #       "Version": "2012-10-17",
  #       "Statement": [
  #           {
  #               "Action": [
  #                   "s3:*"                ],
  #               "Resource": "${var.s3_bucket}/*",
  #               "Effect": "Allow"
  #           }
  #       ]
  #   })
  # }
  inline_policy {
    name = "get-own-tags"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Condition": {
                    "StringEquals": {
                        "ec2:Region": "${var.aws_region}"
                    }
                },
                "Action": "ec2:DescribeInstance*",
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    })
  }
  tags = {
    Name      = "${var.vpc.tags["Name"]}-service_role"
  }
}


# IAM instance profile

resource "aws_iam_instance_profile" "instance_profile" {
  name  = var.vpc.tags["Name"]
  role = aws_iam_role.service_role.name
}
