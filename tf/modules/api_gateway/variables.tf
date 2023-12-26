variable "name" {
  type        = string
  description = "HTTP API name"
  default     = "varonis-datrestaurant-api"
}

variable "description" {
  type        = string
  description = "Description of API"
  default     = "HTTP API for Lambda function"
}

variable "protocol_type" {
  type        = string
  description = "API protocol. Valid values: HTTP, WEBSOCKET"
  default     = "HTTP"
}

variable "log_retention" {
  type        = number
  description = "API GW Logs retention period in days"
  default     = 14
}

variable "payload_format_version" {
  type        = string
  description = "The format of the payload sent to an integration. Valid values: 1.0, 2.0"
  default     = "2.0"
}

variable "allow_methods" {
  type        = set(string)
  description = "Set of allowed HTTP methods"
  default = [
    "GET",
    "HEAD",
    "OPTIONS",
  ]
}

variable "allow_origins" {
  type        = set(string)
  description = "Set of allowed origins"
  default = [
    "*",
  ]
}

variable "allow_headers" {
  type        = set(string)
  description = "Set of allowed HTTP headers."
  default     = []
}

variable "expose_headers" {
  type        = set(string)
  description = "Set of exposed HTTP headers"
  default     = []
}

variable "max_age" {
  type        = number
  description = "Number of seconds that the browser should cache preflight request results"
  default     = 0
}

variable "allow_credentials" {
  type        = bool
  description = "Whether credentials are included in the CORS request"
  default     = false
}

variable "routes" {
  type = set(
    object({
      id                   = string
      resource             = string
      method               = string
      lambda_invoke_arn    = string
      lambda_function_name = string
    })
  )
  description = <<-EOF
      A set of objects, each object maps a method at a resource to a given lambda function.
      Example:
      routes = [
        {
          id                   = "abcd"
          resource             = "restaurants"
          method               = "GET"
          lambda_invoke_arn    = "<replace-with-lambda-function-invoke-arn>"
          lambda_function_name = "<replace-with-lambda-function-name>"
        }
      ]
EOF
}
