terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "tf-learning-rg"
  location = "Japan East"

  tags = {
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}