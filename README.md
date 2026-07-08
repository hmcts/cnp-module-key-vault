# Module key vault

This is a terraform module for creating an azure key vault resource

## Usage
```hcl
module "key_vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = "rhubarb-fe-${var.env}" // Max 24 characters
  product             = var.product
  env                 = var.env
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  product_group_name  = "Your AAD group" # e.g. MI Data Platform, or dcd_cmc
  common_tags         = var.common_tags
}
```

## Notes

The module creates the following permissions:
 - Jenkins access to Keyvault
 - Managed Identity ($product)-$env-mi
 - Product team/developers access

## RBAC authorization

By default the module uses [vault access policies](https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy) for data-plane authorization.
Set `enable_rbac_authorization = true` to switch to [Azure RBAC](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide) instead.
When enabled, access policies are not created and the following role assignments are made in their place:

| Identity | Role |
|---|---|
| `object_id` (creator / pipeline caller) | Key Vault Administrator |
| `jenkins_object_id` | Key Vault Administrator |
| `product_group_name` / `product_group_object_id` (product team) | Key Vault Administrator |
| `managed_identity_object_ids` / `managed_identity_object_id` | Key Vault Secrets User |
| `additional_managed_identities_access` | Key Vault Secrets User |
| Implicitly created managed identity (`create_managed_identity = true`) | Key Vault Secrets User |
| `DTS CFT Developers` group (non-prod only) | Key Vault Secrets User |

### Basic RBAC usage

```hcl
module "key_vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product                 = var.product
  env                     = var.env
  object_id               = data.azurerm_client_config.current.object_id
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "Your AAD group"
  enable_rbac_authorization = true
  common_tags             = var.common_tags
}
```

### Additional role assignments

Use `additional_role_assignments` to grant extra identities access to the vault beyond the defaults.
This is only used when `enable_rbac_authorization = true`.

```hcl
module "key_vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product                 = var.product
  env                     = var.env
  object_id               = data.azurerm_client_config.current.object_id
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "Your AAD group"
  enable_rbac_authorization = true
  common_tags             = var.common_tags

  additional_role_assignments = [
    {
      object_id            = azurerm_user_assigned_identity.app.principal_id
      role_definition_name = "Key Vault Secrets User"
    },
    {
      object_id            = data.azuread_group.soc_team.object_id
      role_definition_name = "Key Vault Reader"
    },
  ]
}
```

### Migrating from access policies to RBAC

Switching an existing vault from access policy mode to RBAC is a two-step change:

1. Set `enable_rbac_authorization = true` in the module call.
2. Ensure the identity running `terraform apply` has the `Owner` or `User Access Administrator` role on the vault (or its resource group / subscription) — this permission is required to change the vault's authorization model and to create role assignments.

> **Note:** `moved` blocks are included in the module so that existing access policy resources are cleanly removed from state rather than destroyed and recreated. No manual state manipulation is needed.

## Reading secrets

All developers have access to read non production secrets if they are a member of the `DTS CFT Developers` Azure AD group

Reading of production secrets is discouraged, in general you should overwrite the secret rather than trying to read it.

_If you really really need that secret then ask the Platform Operations team to get it for you._

Reading a secret via Azure CLI:
```bash
$ az keyvault secret show --vault-name $VAULT --name $SECRET
```

## Writing secrets to key vaults
The product group for the key vault have permissions to update / write / list / delete secrets in all environments
This should be your teams AD group, it's controlled by the `product_group_object_id` variable

You should always write secrets via the command line, as you normally don't have read access on the production vault, but you can still write the secrets via CLI.

```bash
$ az keyvault secret set --vault-name $VAULT_NAME --name "${SECRET_NAME}" --value "${SECRET_VALUE}"
```

More docs can be found here:
https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest

### product_group_object_id (deprecated)

_Note: Historically this module couldn't look up groups by display name, that is now available in `product_group_name`_

The product group object id is the Azure AD group object_id of users
who should be allowed to write secrets into the vault
(note they can't read the secrets after writing).

Useful commands for finding your group object id:

List all reform groups:
```bash
$ az ad group list --query "[?contains(displayName, 'dcd_')].{DisplayName: displayName, id: id}" -o table
```

Retrieve by name if you know the display name:
```bash
$ az ad group list --query "[?displayName=='dcd_devops'].{DisplayName: displayName, id: id}" -o table
```

## Keyvault access using Access Control List
Allow the jenkins subnet id e.g [data.azurerm_subnet.jenkins_subnet.id] and others
Allow the listed set of IPs
```hcl
# Set by the Jenkins pipeline
variable "mgmt_subscription_id" {}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = var.mgmt_subscription_id
  features {}
}

# for SDS
data "azurerm_subnet" "jenkins_subnet" {
  provider             = azurerm.mgmt
  name                 = "iaas"
  virtual_network_name = var.env == "sbox" ? "ss-ptlsbox-vnet" : "ss-ptl-vnet"
  resource_group_name  = var.env == "sbox" ? "ss-ptlsbox-network-rg" : "ss-ptl-network-rg"
}

# for CFT
data "azurerm_subnet" "jenkins_subnet" {
  provider             = azurerm.mgmt
  name                 = "iaas"
  virtual_network_name = "cft-ptl-vnet"
  resource_group_name  = "cft-ptl-network-rg"
}

module "key_vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
 #...
  network_acls_allowed_subnet_ids = [data.azurerm_subnet.jenkins_subnet.id] 
  network_acls_allowed_ip_ranges = ["IPs"]
  network_acls_default_action = "Deny" # Allow by default
}
```

## Application access using Managed Identities
If your application is running in kubernetes it will retrieve the secrets with a managed identity.

Teams can use single Manage Identity for all the key vaults owned by a team.

In order to allow the managed identity access you need to either :

#### Create a new Managed Identity

Add an additional variable to the module (`create_managed_identity`) which will create a managed identity and creates necessary access policy.
```hcl
module "this" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
 #...
  create_managed_identity = true
}
```
Object Id and Client id are available in terraform output.

#### Use an Existing MI
Add the `managed_identity_object_ids` variable to the module with an existing managed identity.

```hcl
data "azurerm_user_assigned_identity" "cmc-identity" {
 name                = "${var.product}-${var.env}-mi"
 resource_group_name = "managed-identities-${var.env}-rg"
}

module "key_vault" { 
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  #...
  managed_identity_object_ids = [data.azurerm_user_assigned_identity.cmc-identity.principal_id]
}

```

### Accessing Managed Identity details
You may need to join the readers group for the subscription in order to see the manged identity

It can be retrieved with: 
```bash
$ az identity show --name <identity-name>-sandbox-mi -g managed-identities-<env>-rg --subscription <Subscription> --query principalId -o tsv
```

i.e. for sandbox 
```bash
$ az identity show --name cnp-sandbox-mi -g managed-identities-sbox-rg --subscription DCD-CFT-Sandbox --query principalId -o tsv
```

### Private endpoints

To enable private endpoints:

```terraform
locals {
  private_endpoint_rg_name   = var.businessArea == "sds" ? "ss-${var.env}-network-rg" : "${var.businessArea}-${var.env}-network-rg"
  private_endpoint_vnet_name = var.businessArea == "sds" ? "ss-${var.env}-vnet" : "${var.businessArea}-${var.env}-vnet"
}
# CFT only, on SDS remove this provider
provider "azurerm" {
  alias           = "private_endpoints"
  subscription_id = var.aks_subscription_id
  features {}
  skip_provider_registration = true
}
data "azurerm_subnet" "private_endpoints" {
  # CFT only you will need to provide an extra provider, uncomment the below line, on SDS remove this line and the next
  # azurerm.private_endpoints
  resource_group_name  = local.private_endpoint_rg_name
  virtual_network_name = local.private_endpoint_vnet_name
  name                 = "private-endpoints"
}

module "this" {
  source                     = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                       = "rhubarb-fe-${var.env}" // Max 24 characters
  product                    = var.product
  env                        = var.env
  object_id                  = var.jenkins_AAD_objectId
  resource_group_name        = azurerm_resource_group.rg.name
  product_group_name         = "Your AAD group" # e.g. MI Data Platform, or dcd_cmc
  private_endpoint_subnet_id = data.azurerm_subnet.endpoint_subnet.id
  common_tags                = var.common_tags
}
```

variables.tf:

```terraform
variable "businessArea" {
  default = "" # sds or cft, fill this in
}
```