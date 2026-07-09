# These moved blocks preserve the Terraform state addresses of resources that
# previously had no count meta-argument (and were therefore addressed without
# an index) after count was added. Without them, Terraform would plan to delete
# the existing resource and create a new one at the [0] address.

moved {
  from = azurerm_key_vault_access_policy.creator_access_policy
  to   = azurerm_key_vault_access_policy.creator_access_policy[0]
}

moved {
  from = azurerm_key_vault_access_policy.product_team_access_policy
  to   = azurerm_key_vault_access_policy.product_team_access_policy[0]
}
