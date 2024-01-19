output "restaurants_endpoint" {
  value = "${module.azure_function.function_app_endpoint}/api/restaurants"
  description = "API endpoint for restaurants function"
}