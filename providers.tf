terraform {
  required_version = ">=1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-remote-state-rg"
    storage_account_name = "remotestatestorageslz"
    container_name       = "tfstate"
    key                  = "slz-prod.tfstate"
    use_azuread_auth     = true
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

