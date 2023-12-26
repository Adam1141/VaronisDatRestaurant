variable "lambda_source_file_path" {
  type        = string
  description = "Path to Lambda python file"
  default     = "../src/lambda.py"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of Lambda function to create"
  default     = "varonis-datrestaurant-lambda"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.10"
}

variable "logging_s3_bucket_name" {
  type        = string
  description = "Name of S3 bucket used to log requests/respones"
  default     = "varonis-datrestaurant-logging"
}

variable "restaurants_s3_bucket_name" {
  type        = string
  description = "Name of S3 bucket that will contain the restaurants JSON file"
  default     = "varonis-datrestaurant-restaurants"
}

variable "s3_restaurants_key" {
  type        = string
  description = "S3 key for the restaurants JSON file inside the restaurants bucket"
  default     = "restaurants.json"
}

variable "lambda_max_returned_results" {
  type        = number
  description = "Maximum number of returned results (matching restaurants)"
  default     = 5
}

variable "restaurants_file_path" {
  type        = string
  description = "Path to restaurants JSON file"
  default     = "../restaurants.json"
}
