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

variable "enable_rbac_authorization" {
  type        = bool
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  default     = false
}

variable "additional_role_assignments" {
  type = map(object({
    object_id = string
    role_name = string
  }))
  description = "Additional Role Assignments to the Key Vault using pre-defined roles from Azure"
  default     = {}
}