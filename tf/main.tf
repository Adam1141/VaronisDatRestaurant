resource "aws_s3_bucket" "logging" {
  bucket = var.logging_s3_bucket_name
}

resource "aws_s3_bucket" "restaurants" {
  bucket = var.restaurants_s3_bucket_name
}

resource "aws_s3_object" "restaurants_file" {
  bucket     = var.restaurants_s3_bucket_name
  key        = var.s3_restaurants_key
  source     = var.restaurants_file_path
  etag       = filemd5(var.restaurants_file_path)
  depends_on = [aws_s3_bucket.restaurants]
}

module "lambda" {
  source           = "./modules/lambda"
  function_name    = var.lambda_function_name
  source_file_path = abspath(var.lambda_source_file_path)
  runtime          = var.lambda_runtime
  environment = {
    S3_LOGGING_BUCKET     = var.logging_s3_bucket_name
    S3_RESTAURANTS_BUCKET = var.restaurants_s3_bucket_name
    S3_RESTAURANTS_KEY    = var.s3_restaurants_key
    MAX_RETURNED_RESULTS  = var.lambda_max_returned_results
  }
  depends_on = [aws_s3_bucket.logging, aws_s3_bucket.restaurants, aws_s3_object.restaurants_file]
}

module "api_gateway" {
  source = "./modules/api_gateway"
  routes = [
    {
      id                   = "1"
      resource             = "/restaurants"
      method               = "GET"
      lambda_invoke_arn    = module.lambda.lambda_invoke_arn
      lambda_function_name = var.lambda_function_name
    }
  ]
  depends_on = [module.lambda]
}

# used to delete archives created for Lambda code when running locally
resource "terraform_data" "post_apply" {
  depends_on = [module.lambda]
  triggers_replace = [
    timestamp()
  ]
  provisioner "local-exec" {
    command = "rm ${module.lambda.lambda_archive_filename}"
  }
}
