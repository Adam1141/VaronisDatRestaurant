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
  default     = "functions.zip"
  description = "Path to Azure Function App archive for upload to SA Container"
}

variable "restaurants_file_path" {
  type = string
  default = "../restaurants.json"
  description = "Path to restaurants JSON file"
}

variable "max_returned_results" {
  type = number
  default = 5
  description = "Max returned results from SQL query on restaurants JSON file"
}