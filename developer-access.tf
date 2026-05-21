locals {
  is_prod                    = length(regexall(".*(prod).*", var.env)) > 0
  developers_group_object_id = var.developers_group_object_id != "" ? var.developers_group_object_id : data.azuread_group.developers[0].object_id
}

resource "azurerm_key_vault_access_policy" "developer" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = local.developers_group_object_id
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

  count = local.is_prod ? 0 : 1
}
