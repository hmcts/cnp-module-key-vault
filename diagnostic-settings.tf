# DTSPO-35095: AAT AuditEvent DIAG logs are disabled in aat.
resource "azurerm_monitor_diagnostic_setting" "kv-ds" {
  count                      = var.env != "aat" ? 1 : 0
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
