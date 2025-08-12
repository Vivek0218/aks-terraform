# Azure Provider source and version being used
terraform {
  required_version = "> 1.0.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.117.0"
    }
  }
  backend "azurerm" {}
}

# Providers
provider "azurerm" {
  features {}
}
