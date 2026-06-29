locals {
  preview_jenkins_object_ids = var.grant_preview_jenkins_access && var.env == "aat" ? data.azurerm_user_assigned_identity.jenkins_preview[*].principal_id : []
  dev_jenkins_object_ids     = var.grant_dev_jenkins_access && var.env == "stg" ? data.azuread_service_principal.jenkins_dev[*].object_id : []
  managed_identity_list      = toset(compact(concat(var.managed_identity_object_ids, [var.managed_identity_object_id], local.preview_jenkins_object_ids, local.dev_jenkins_object_ids)))
  env                        = replace(var.env, "idam-", "")
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

  for_each = local.managed_identity_list
}

resource "azurerm_key_vault_access_policy" "managed_identity_names_access_policy" {

  key_vault_id = azurerm_key_vault.kv.id
  object_id    = data.azurerm_user_assigned_identity.additional_managed_identities_access[each.value].principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]

  for_each = toset(var.additional_managed_identities_access)
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

  count = var.create_managed_identity ? 1 : 0
}
