# TODO make a breaking change at some point to automatically default a subnet id like in:
# https://github.com/hmcts/terraform-module-servicebus-namespace/blob/1b9bd99b936710ab63aeb89c167266f2ad0b09ba/private-endpoint.tf#L1-L15
resource "azurerm_private_endpoint" "this" {
  # count has to be resolvable at plan time, so it cannot be inferred from a subnet
  # id that the same plan is still creating - that value is unknown until apply.
  # enable_private_endpoint lets the caller state the intent directly; when it is
  # unset this is exactly the previous expression.
  count = var.enable_private_endpoint == null ? (var.private_endpoint_subnet_id != null ? 1 : 0) : (var.enable_private_endpoint ? 1 : 0)

  name                = var.private_endpoint_name == null ? "${local.vault_name}-vault-pe" : var.private_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = local.vault_name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "endpoint-dnszonegroup"
    private_dns_zone_ids = ["/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
  }

  tags = var.common_tags
}
