data "azurerm_client_config" "current" {}

data "azuread_service_principal" "current" {
  client_id = data.azurerm_client_config.current.client_id
}

data "azuread_group" "developers" {
  display_name = var.developers_group
}

data "azurerm_user_assigned_identity" "additional_managed_identities_access" {
  for_each            = toset(var.additional_managed_identities_access)
  name                = "${each.value}-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

data "azurerm_user_assigned_identity" "jenkins_preview" {
  count               = var.grant_preview_jenkins_access && var.env == "aat" ? 1 : 0
  name                = "jenkins-preview-mi"
  resource_group_name = "managed-identities-preview-rg"
}

data "azuread_service_principal" "jenkins_dev" {
  count        = var.grant_dev_jenkins_access && var.env == "stg" ? 1 : 0
  display_name = "jenkins-dev-mi"
}

data "azurerm_user_assigned_identity" "jenkins_ptl" {
  name = var.env != "sbox" ? (
    local.business_area == "cft" ? "jenkins-cftptl-intsvc-mi" : "jenkins-cftsbox-intsvc-mi"
    ) : (
    local.business_area == "sds" ? "jenkins-ptl-mi" : "jenkins-ptlsbox-mi"
  )
  resource_group_name = var.env != "sbox" ? (
    local.business_area == "cft" ? "jenkins-managed-identities-cftptl-intsvc-rg" : "jenkins-managed-identities-cftsbox-intsvc-rg"
    ) : (
    local.business_area == "sds" ? "jenkins-managed-identities-ptl-rg" : "jenkins-managed-identities-ptlsbox-rg"
  )
}

data "azuread_group" "product_team" {
  display_name     = var.product_group_name
  security_enabled = true

  count = var.product_group_name == "" ? 0 : 1
}
