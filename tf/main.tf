resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.rg
}

resource "azurerm_storage_account" "data" {
  name                     = "sa${var.project_name}"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_container" "logging" {
  name                 = "logging"
  storage_account_name = azurerm_storage_account.data.name
}

resource "azurerm_storage_container" "restaurants" {
  name                 = "restaurants"
  storage_account_name = azurerm_storage_account.data.name
}

resource "azurerm_storage_blob" "restaurants" {
  name                   = "restaurants.json"
  storage_account_name   = azurerm_storage_account.data.name
  storage_container_name = azurerm_storage_container.restaurants.name
  type                   = "Block"
  content_type           = "application/json"
  content_md5            = filemd5(var.restaurants_file_path)
  source                 = var.restaurants_file_path
}

module "azure_function" {
  source                   = "./modules/azure_function"
  source_dir               = abspath(var.source_dir)
  archive_output_path      = abspath(var.archive_output_path)
  logging_container_id     = azurerm_storage_container.logging.resource_manager_id
  restaurants_container_id = azurerm_storage_container.restaurants.resource_manager_id
  app_settings = {
    SA                       = azurerm_storage_account.data.name
    SA_LOGGING_CONTAINER     = azurerm_storage_container.logging.name
    SA_RESTAURANTS_CONTAINER = azurerm_storage_container.restaurants.name
    SA_RESTAURANTS_BLOB      = azurerm_storage_blob.restaurants.name
    MAX_RETURNED_RESULTS     = var.max_returned_results
  }

  depends_on = [
    azurerm_storage_container.logging,
    azurerm_storage_container.restaurants,
    azurerm_storage_blob.restaurants
  ]
}


resource "terraform_data" "remove_function_app_archive" {
  triggers_replace = [
    timestamp()
  ]

  provisioner "local-exec" {
    command = "rm ${var.archive_output_path}"
  }

  depends_on = [module.azure_function]
}
