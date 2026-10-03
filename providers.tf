terraform {
  required_version = ">=1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}
provider "azurerm" {
  features {}
}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

data "azurerm_client_config" "current" {
}