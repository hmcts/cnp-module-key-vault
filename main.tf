locals {
  vault_name                 = var.name == "" ? format("%s-%s", var.product, var.env) : var.name
  excluded_sp_name_fragments = ["cftptl", "cftsbox", "ptl", "ptlsbox"]
  business_area              = lower(lookup(var.common_tags, "business_area", "cft")) == "cft" ? "cft" : "sds"
}

resource "azurerm_key_vault" "kv" {
  name                = local.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name  = var.sku
  tenant_id = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = var.purge_protection_enabled

  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.network_acls_default_action # Default is "Allow" for compatibility
    ip_rules                   = var.network_acls_allowed_ip_ranges
    virtual_network_subnet_ids = var.network_acls_allowed_subnet_ids
  }

  tags = var.common_tags
}

moved {
  from = azurerm_key_vault_access_policy.creator_access_policy
  to   = azurerm_key_vault_access_policy.jenkins_ptl
}
