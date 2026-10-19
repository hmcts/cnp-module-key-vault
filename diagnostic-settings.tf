# Keep AuditEvent diagnostics only for production environments.
resource "azurerm_monitor_diagnostic_setting" "kv-ds" {
  count                      = contains(["idam-prod", "idam-prod2", "idam-vault-prod", "idam-vault-prod2", "prod", "mgmt", "ldata", "prod-int", "ptl"], var.env) ? 1 : 0
  name                       = local.vault_name
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id

  enabled_log {
    category = "AuditEvent"
  }
}

module "log_analytics_workspace" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.env
}
