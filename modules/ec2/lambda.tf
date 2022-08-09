# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

# data "aws_region" "current" {}
# locals {
#   aws-region = data.aws_region.current.name
# }

# resource "local_file" "lambda_function" {
#   content = templatefile("${path.module}/lambda/test.py.tpl", {
#     region    = local.aws-region
#   })
#   filename =  "${path.module}/lambda/test.py"

#   file_permission      = 0644
#   directory_permission = 0755
# }

# data "archive_file" "lambda_function" {
#   type             = "zip"
#   source_file      = "${path.module}/lambda/test.py"
#   output_file_mode = "0644"
#   output_path      = "${path.module}/files/lambda-test.zip"

#   depends_on = [
#     local_file.lambda_function
#   ]
# }

# module "lambda_function" {
#   source = "../modules/lambda"

#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn

#   filename         = data.archive_file.lambda_function.output_path
#   handler          = "test.lambda_handler"
#   source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)
# #   source_code_hash = data.archive_file.lambda_function.output_base64sha256
# }