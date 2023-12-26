variable "source_file_path" {
  type        = string
  description = "Path to Lambda python file"
}

variable "function_name" {
  type        = string
  description = "Name of Lambda function to create"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
}

variable "handler" {
  type        = string
  description = "Lambda handler name"
  default     = "lambda.lambda_handler"
}

variable "lambda_archive_filename" {
  type        = string
  description = "Name of archive created to upload Lambda code"
  default     = "lambda_function_payload.zip"
}

variable "lambda_archive_type" {
  type        = string
  description = "Archive type to use for Lambda code archive"
  default     = "zip"
}

variable "environment" {
  type        = map(string)
  description = "Environemnt variables that Lambda code can access during execution"
  default     = {}
}
