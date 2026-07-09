data "azuread_group" "developers" {
  display_name = var.developers_group
}

locals {
  is_prod = length(regexall(".*(prod).*", var.env)) > 0
}

resource "azurerm_key_vault_access_policy" "developer" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = data.azuread_group.developers.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  count = var.enable_rbac_authorization ? 0 : (local.is_prod ? 0 : 1)
}
