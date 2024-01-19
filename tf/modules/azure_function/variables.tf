variable "project_name" {
  type    = string
  default = "azurefunction"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "rg" {
  type    = string
  default = "azure_function_rg"
}

variable "source_dir" {
  type        = string
  default     = "../src"
  description = "Path to root directory of Azure Function App code and config"
}

variable "archive_output_path" {
  type        = string
  default     = "./functions.zip"
  description = "Path to Azure Function App archive for upload to SA Container"
}

variable "logging_container_id" {
  type        = string
  description = "ID of logging container, used to assign role"
}

variable "restaurants_container_id" {
  type        = string
  description = "ID of restaurants container, used to assign role"
}

variable "app_settings" {
  type        = map(any)
  description = "App Settings for Azure Function App"
}
