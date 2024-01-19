output "function_app_endpoint" {
  value = "https://${azurerm_function_app.function_app.name}.azurewebsites.net"
  description = "API endpoint for the Azure Function App"
}

