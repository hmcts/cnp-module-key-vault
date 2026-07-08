provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
}

data "azurerm_client_config" "current" {}

# An example of an additional identity that needs read access to secrets —
# e.g. a separately managed application identity.
resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.product}-app-${var.env}-mi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

module "vault" {
  source              = "../../"
  product             = var.product
  env                 = var.env
  object_id           = data.azurerm_client_config.current.object_id
  resource_group_name = azurerm_resource_group.rg.name
  product_group_name  = "DTS Platform Operations"
  common_tags         = var.common_tags

  enable_rbac_authorization = true

  # Grant extra identities access on top of the module defaults.
  additional_role_assignments = {
    app_identity = {
      object_id            = azurerm_user_assigned_identity.app.principal_id
      role_definition_name = "Key Vault Secrets User"
    }
  }
}

variable "common_tags" {
  default = {}
}

variable "product" {
  default = "hmcts-demo"
}

variable "env" {
  default = "sandbox"
}

variable "location" {
  default = "UK South"
}
