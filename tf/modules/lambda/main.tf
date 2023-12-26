data "archive_file" "lambda" {
  type        = var.lambda_archive_type
  source_file = var.source_file_path
  output_path = var.lambda_archive_filename
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name}-Role"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
EOF
}

resource "aws_lambda_function" "lambda" {
  filename         = var.lambda_archive_filename
  function_name    = var.function_name
  runtime          = var.runtime
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  source_code_hash = data.archive_file.lambda.output_base64sha256


  environment {
    variables = var.environment
  }
}
