resource "azurerm_key_vault_access_policy" "jenkins" {
  count        = var.jenkins_object_id != "" ? 1 : 0
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = var.jenkins_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "SetIssuers",
    "Update",
    "ManageContacts",
    "ManageIssuers",
  ]

  key_permissions = [
    "Create",
    "List",
    "Get",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "Sign",
    "Verify",
    "GetRotationPolicy",
  ]

  secret_permissions = [
    "Set",
    "List",
    "Get",
    "Delete",
    "Recover",
    "Purge",
  ]
}

resource "azurerm_key_vault_access_policy" "jenkins_ptl" {
  # This is needed in some instances of nightly pipelines
  # Re-adding this until that is reconfigured

  key_vault_id = azurerm_key_vault.kv.id

  object_id = data.azuread_service_principal.jenkins_ptl.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "SetIssuers",
    "Update",
    "ManageContacts",
    "ManageIssuers",
  ]

  key_permissions = [
    "Create",
    "List",
    "Get",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "Sign",
    "Verify",
    "GetRotationPolicy",
  ]

  secret_permissions = [
    "Set",
    "List",
    "Get",
    "Delete",
    "Recover",
    "Purge",
  ]
}
