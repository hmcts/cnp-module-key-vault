variable "name" {
  default     = ""
  description = "The vault name (at most 24 characters - Azure Key Vault name limit). If not provided then product-env pair will be used as a default."
}

variable "product" {
  description = "(Required) The name of your application"
}

variable "env" {
  description = "(Required)"
}

variable "resource_group_name" {
  description = "(Required) The resource group you wish to put your Vault in. This has to exist already."
}

variable "tenant_id" {
  description = "(deprecated) does nothing"
  default     = ""
}

variable "object_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  default     = ""
}

variable "vault_name_suffix" {
  default     = "vault"
  description = "Please don't override this default unless required to do so as this will not be complaint with naming convention."
}

variable "location" {
  default     = "UK South"
  description = "The name of the Azure region to deploy your vault to. Please use the default by not passing this parameter unless instructed otherwise."
}

variable "product_group_object_id" {
  description = "(deprecated) The AD group of users that should have access to add secrets to the key vault, see the README on where to find this"
  default     = ""
}

variable "product_group_name" {
  description = "The AD group of users that should have access to add secrets to the key vault"
  default     = ""
}

variable "managed_identity_object_id" {
  default     = ""
  description = "the object id of the managed identity - can be retrieved with az identity show --name <identity-name>-sandbox-mi -g managed-identities-<env>-rg --subscription DCD-CFTAPPS-<env> --query principalId -o tsv"
}

variable "common_tags" {
  type = map(string)
}

variable "sku" {
  default     = "standard"
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
}

variable "managed_identity_object_ids" {
  type    = list(string)
  default = []
}

variable "create_managed_identity" {
  default = false
}

variable "soft_delete_enabled" {
  default     = true
  description = "(deprecated) does nothing"
}

variable "developers_group" {
  default = "DTS CFT Developers"
}

variable "network_acls_allowed_ip_ranges" {
  description = "IP Address space Allowed"
  type        = list(string)
  default     = []
}

variable "network_acls_default_action" {
  default = "Allow"
}

variable "network_acls_allowed_subnet_ids" {
  description = "Allowed subnet id(s)"
  type        = list(string)
  default     = []
}

variable "purge_protection_enabled" {
  default = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID to attach private endpoint to - overrides the default subnet id"
  default     = null
}

variable "private_endpoint_name" {
  default = null
}

variable "additional_managed_identities_access" {
  type    = list(string)
  default = []
}

variable "jenkins_object_id" {
  description = "The object ID of the environment specific Jenkins managed identity"
  default     = ""
}

variable "grant_preview_jenkins_access" {
  description = "Temporary opt-in for preview deployments that still read AAT vault secrets. When true for env=aat, grants jenkins-preview-mi Get/List access."
  type        = bool
  default     = false
}

variable "grant_dev_jenkins_access" {
  description = "Temporary opt-in for dev deployments that still read STG vault secrets. When true for env=stg, grants jenkins-dev-mi Get/List access."
  type        = bool
  default     = false
}
