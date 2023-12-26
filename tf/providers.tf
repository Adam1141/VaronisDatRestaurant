terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "varonis-datrestaurant-tf-state-20231226"
    key            = "varonis/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "varonis-datrestaurant-tf-state-lock-20231226"
    encrypt        = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  required_version = "~> 1.6.6"
}

provider "aws" {
  region = var.region
}
