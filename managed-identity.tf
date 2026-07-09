locals {
  managed_identity_list = toset(compact(concat(var.managed_identity_object_ids, [var.managed_identity_object_id])))
  env                   = replace(var.env, "idam-", "")
}

resource "azurerm_user_assigned_identity" "managed_identity" {

  resource_group_name = "managed-identities-${local.env}-rg"
  location            = var.location

  name = "${var.product}-${local.env}-mi"

  tags  = var.common_tags
  count = var.create_managed_identity ? 1 : 0
}

resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = each.value
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

  for_each = var.enable_rbac_authorization ? toset([]) : local.managed_identity_list
}

data "azurerm_user_assigned_identity" "additional_managed_identities_access" {
  for_each            = toset(var.additional_managed_identities_access)
  name                = "${each.value}-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

resource "azurerm_key_vault_access_policy" "managed_identity_names_access_policy" {

  key_vault_id = azurerm_key_vault.kv.id
  object_id    = data.azurerm_user_assigned_identity.additional_managed_identities_access[each.value].principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]

  for_each = var.enable_rbac_authorization ? toset([]) : toset(var.additional_managed_identities_access)
}

resource "azurerm_key_vault_access_policy" "implicit_managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  object_id = azurerm_user_assigned_identity.managed_identity[0].principal_id
  tenant_id = data.azurerm_client_config.current.tenant_id

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

  count = !var.enable_rbac_authorization && var.create_managed_identity ? 1 : 0
}
