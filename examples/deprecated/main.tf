provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
}

module "vault" {
  source                  = "../../"
  product                 = var.product
  env                     = var.env
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_object_id = "4d0554dd-fe60-424a-be9c-36636826d927" # e.g. MI Data Platform, or dcd_cmc
  object_id               = data.azurerm_client_config.current.object_id
  tenant_id               = "12434"
  common_tags             = var.common_tags
}

variable "common_tags" {
  default = {}
}

variable "product" {
  default = "hmcts-module"
}

variable "env" {
  default = "sandbox"
}

variable "location" {
  default = "UK South"
}
