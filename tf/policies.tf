resource "aws_iam_policy" "lambda_role_policy" {
  name   = "${var.lambda_function_name}-Policy"
  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:*:*:*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:ListBucket"
          ],
          "Resource": [
            "arn:aws:s3:::${var.restaurants_s3_bucket_name}",
            "arn:aws:s3:::${var.restaurants_s3_bucket_name}/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl"
          ],
          "Resource": [
            "arn:aws:s3:::${var.logging_s3_bucket_name}",
            "arn:aws:s3:::${var.logging_s3_bucket_name}/*"
          ]
        }
      ]
    }
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
}
