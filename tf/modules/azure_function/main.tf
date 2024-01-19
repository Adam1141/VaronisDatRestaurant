resource "random_id" "rnd" {
  byte_length = 4
}

resource "terraform_data" "install_requirements" {
  triggers_replace = {
    requirements_md5 = filemd5("${var.source_dir}/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<-EOF
      python -m venv .venv
      . .venv
      pip install --target='.python_packages/lib/site-packages' -r requirements.txt"
    EOF

    working_dir = var.source_dir
  }
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.archive_output_path

  depends_on = [terraform_data.install_requirements]
}

resource "azurerm_storage_account" "storage_account_function" {
  name                     = "sa${var.project_name}${random_id.rnd.hex}"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "storage_container_function" {
  name                 = "function-releases"
  storage_account_name = azurerm_storage_account.storage_account_function.name
}

resource "azurerm_storage_blob" "storage_blob_function" {
  name                   = "functions-${substr(data.archive_file.function.output_md5, 0, 6)}.zip"
  storage_account_name   = azurerm_storage_account.storage_account_function.name
  storage_container_name = azurerm_storage_container.storage_container_function.name
  type                   = "Block"
  content_md5            = data.archive_file.function.output_md5
  source                 = var.archive_output_path
}

resource "azurerm_application_insights" "app-insights" {
  application_type    = "web"
  location            = var.location
  name                = "app-${var.project_name}"
  resource_group_name = var.rg
}

resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}"
  location            = var.location
  resource_group_name = var.rg
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_function_app" "function_app" {
  resource_group_name        = var.rg
  app_service_plan_id        = azurerm_service_plan.main.id
  location                   = var.location
  storage_account_name       = azurerm_storage_account.storage_account_function.name
  storage_account_access_key = azurerm_storage_account.storage_account_function.primary_access_key
  name                       = "fa-${var.project_name}"
  enable_builtin_logging     = false
  os_type                    = "linux"
  version                    = "~4"

  site_config {
    linux_fx_version          = "python|3.10"
    use_32_bit_worker_process = false
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME"       = "python"
      "WEBSITE_RUN_FROM_PACKAGE"       = azurerm_storage_blob.storage_blob_function.url
      "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app-insights.instrumentation_key
    },
    var.app_settings
  )
}

resource "azurerm_role_assignment" "role_assignment_storage" {
  scope                = azurerm_storage_account.storage_account_function.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_function_app.function_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "logging_container" {
  scope                = var.logging_container_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app.function_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "restaurants_container" {
  scope                = var.restaurants_container_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_function_app.function_app.identity.0.principal_id
}
