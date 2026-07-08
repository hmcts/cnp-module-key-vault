# Role assignments are only created when enable_rbac_authorization = true.
# They mirror the access policies defined elsewhere in this module so that
# switching to RBAC mode preserves the same effective permissions.

# Creator identity — full Key Vault Administrator access.
resource "azurerm_role_assignment" "creator" {
  count                = var.enable_rbac_authorization && var.object_id != "" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.object_id
}

# Jenkins managed identity — full Key Vault Administrator access.
resource "azurerm_role_assignment" "jenkins" {
  count                = var.enable_rbac_authorization && var.jenkins_object_id != "" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.jenkins_object_id
}

# Developer group — read secrets in non-prod environments only.
resource "azurerm_role_assignment" "developer" {
  count                = var.enable_rbac_authorization && !local.is_prod ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_group.developers.object_id
}

# Managed identities supplied by object ID — read secrets.
resource "azurerm_role_assignment" "managed_identity" {
  for_each             = var.enable_rbac_authorization ? local.managed_identity_list : toset([])
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

# Managed identities supplied by name via additional_managed_identities_access — read secrets.
resource "azurerm_role_assignment" "managed_identity_names" {
  for_each             = var.enable_rbac_authorization ? toset(var.additional_managed_identities_access) : toset([])
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.additional_managed_identities_access[each.value].principal_id
}

# Implicitly created managed identity (when create_managed_identity = true) — read secrets.
resource "azurerm_role_assignment" "implicit_managed_identity" {
  count                = var.enable_rbac_authorization && var.create_managed_identity ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.managed_identity[0].principal_id
}

# Product team AD group — full Key Vault Administrator access.
resource "azurerm_role_assignment" "product_team" {
  count                = var.enable_rbac_authorization && local.product_group_object_id != "" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = local.product_group_object_id
}
