resource "aws_apigatewayv2_api" "http" {
  name          = var.name
  description   = var.description
  protocol_type = var.protocol_type

  cors_configuration {
    allow_credentials = var.allow_credentials
    allow_headers     = var.allow_headers
    allow_methods     = var.allow_methods
    allow_origins     = var.allow_origins
    expose_headers    = var.expose_headers
    max_age           = var.max_age
  }
}

resource "aws_apigatewayv2_route" "route" {
  for_each  = { for route in var.routes : route.id => route }
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "${each.value.method} ${each.value.resource}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each               = { for route in var.routes : route.id => route }
  api_id                 = aws_apigatewayv2_api.http.id
  description            = "Lambda integration"
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_invoke_arn
  payload_format_version = var.payload_format_version
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true


  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.http.name}"
  retention_in_days = var.log_retention
}

resource "aws_lambda_permission" "apigw" {
  for_each      = { for route in var.routes : route.id => route }
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
