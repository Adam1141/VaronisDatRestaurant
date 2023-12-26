output "lambda_arn" {
  value       = aws_lambda_function.lambda.arn
  description = "Lambda ARN"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.lambda.invoke_arn
  description = "Lambda Invoke ARN to be used with API Gateway"
}

output "lambda_archive_filename" {
  value       = var.lambda_archive_filename
  description = "Archive file created for uploading Lambda code, output is used to delete it."
}

output "role_name" {
  value       = aws_iam_role.lambda_role.name
  description = "Lambda role name, used to attach policies to the role."
}