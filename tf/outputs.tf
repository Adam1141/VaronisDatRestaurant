output "lambda_arn" {
  value       = module.lambda.lambda_arn
  description = "Lambda ARN"
}

output "api_endpoint" {
  value       = module.api_gateway.api_endpoint
  description = "URL to invoke Lambda function through API Gateway"
}

output "s3_logging_bucket" {
  value       = aws_s3_bucket.logging.id
  description = "Name of logging S3 bucket"
}

output "s3_restaurants_bucket" {
  value       = aws_s3_bucket.restaurants.id
  description = "Name of restaurants file S3 bucket"
}

output "s3_tf_state_bucket" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of S3 bucket used to store terraform state file"
}

output "dynamodb_state_locking_table_name" {
  value       = aws_dynamodb_table.terraform_locks.id
  description = "DynamoDB used for terraform state locking"
}
