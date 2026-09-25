# -----------------------------------------------------------------------------
# versions.tf — which Terraform + providers to use, and WHERE state is stored
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state in Azure Storage (created manually in Task 0).
  # These names are NOT secrets. Authentication comes from the ARM_* environment
  # variables supplied by the pipeline's service connection (or exported locally).
  backend "azurerm" {
    resource_group_name  = "epicbook-tfstate-rg"
    storage_account_name = "epicbooktfstate31971"
    container_name       = "tfstate"
    key                  = "epicbook.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  # Providers were registered manually in Task 0. "none" stops Terraform from
  # trying to register dozens of extra providers on the student subscription.
  resource_provider_registrations = "none"

  # subscription_id is read from the ARM_SUBSCRIPTION_ID environment variable,
  # so it never appears in the code.
}
