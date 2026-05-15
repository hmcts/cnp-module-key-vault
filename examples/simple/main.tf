provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
}
module "vault" {
  source              = "../../"
  product             = var.product
  env                 = var.env
  object_id           = data.azurerm_client_config.current.object_id
  resource_group_name = azurerm_resource_group.rg.name
  product_group_name  = "DTS Platform Operations" # e.g. MI Data Platform, or dcd_cmc
  common_tags         = var.common_tags
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
