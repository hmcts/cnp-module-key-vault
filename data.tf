data "azurerm_client_config" "current" {}

data "azuread_service_principal" "current" {
  client_id = data.azurerm_client_config.current.client_id
}

data "azuread_group" "developers" {
  display_name = var.developers_group
  count        = var.developers_group_object_id == "" ? 1 : 0
}

data "azurerm_user_assigned_identity" "additional_managed_identities_access" {
  for_each            = toset(var.additional_managed_identities_access)
  name                = "${each.value}-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

data "azuread_group" "product_team" {
  display_name     = var.product_group_name
  security_enabled = true

  count = var.product_group_name == "" ? 0 : 1
}
