data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-cftptl-intsvc-mi"
  resource_group_name = "managed-identities-cftptl-intsvc-rg"
}

resource "azurerm_key_vault_access_policy" "jenkins" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id = data.azurerm_user_assigned_identity.jenkins.principal_id
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
