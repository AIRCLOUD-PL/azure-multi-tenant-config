<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-multi-tenant-config

**Multi-tenant configuration module for Azure infrastructure.**

[![CI](https://github.com/AIRCLOUD-PL/azure-multi-tenant-config/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-multi-tenant-config/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-multi-tenant-config?sort=semver)](https://github.com/AIRCLOUD-PL/azure-multi-tenant-config/releases)

This module provides centralized configuration management for multi-tenant and multi-subscription Azure deployments. It standardizes environment-specific defaults, naming conventions, and resource configurations across different environments (dev, test, prod) and tenants.

## Features

- **Environment-specific defaults**: Automatically configures appropriate SKUs, security settings, and compliance requirements based on environment
- **Multi-tenant support**: Manages configurations for multiple tenants with custom overrides
- **Multi-subscription support**: Handles deployments across multiple Azure subscriptions
- **Standardized naming**: Provides consistent naming conventions for all resources
- **Flexible overrides**: Allows environment and tenant-specific customizations
- **Cost optimization**: Environment-specific cost optimization settings
- **Security by design**: Environment-appropriate security configurations
- **Compliance ready**: Built-in compliance and policy management

## Usage

Pin the module to a release tag:

```hcl
module "multi_tenant_config" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-multi-tenant-config.git?ref=v1.0.0"

  # required inputs
  environment  = "..."
  project_name = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

### Basic Usage (Single Tenant)

```hcl
module "config" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-multi-tenant-config.git?ref=v1.0.0"
  
  environment    = "prod"
  location       = "East US"
  project_name   = "myproject"
  organization   = "myorg"
  created_by     = "Platform Team"
  cost_center    = "IT-001"
}

# Use the configuration in other modules
module "key_vault" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-key-vault-module.git?ref=v1.0.0"
  
  name                = module.config.resource_names.key_vault
  location            = module.config.location
  sku_name           = module.config.sku_defaults.key_vault_sku
  enable_soft_delete = module.config.security_defaults.enable_soft_delete
  purge_protection   = module.config.security_defaults.purge_protection
  tags               = module.config.common_tags
}
```

### Multi-Tenant Usage

```hcl
module "config" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-multi-tenant-config.git?ref=v1.0.0"
  
  environment    = "prod"
  location       = "East US"
  project_name   = "platform"
  organization   = "myorg"
  tenant_id      = "tenant-a"
  
  tenant_configurations = {
    "tenant-a" = {
      display_name = "Tenant A Corp"
      domain_name  = "tenanta.com"
      subscriptions = [
        {
          subscription_id = "12345678-1234-1234-1234-123456789012"
          name           = "Tenant A Production"
          role           = "Contributor"
        }
      ]
      custom_settings = {
        security = {
          enable_private_endpoint = true
          retention_days         = 2555  # 7 years for financial data
        }
      }
    }
    "tenant-b" = {
      display_name = "Tenant B LLC"
      domain_name  = "tenantb.com"
      subscriptions = [
        {
          subscription_id = "87654321-4321-4321-4321-210987654321"
          name           = "Tenant B Production"
          role           = "Contributor"
        }
      ]
    }
  }
}
```

### Environment Overrides

```hcl
module "config" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-multi-tenant-config.git?ref=v1.0.0"
  
  environment    = "prod"
  location       = "East US"
  project_name   = "critical-app"
  
  environment_overrides = {
    sku_defaults = {
      vm_size            = "Standard_D8s_v3"  # Larger than default prod
      key_vault_sku      = "premium"          # Premium HSM required
    }
    security = {
      retention_days = 2555  # 7 years retention instead of 1 year
    }
    compliance = {
      enable_custom_policies = true  # Enable custom compliance policies
    }
  }
}
```

## Environment Configurations

### Development (dev)
- **SKUs**: Basic/Standard tiers for cost optimization
- **Security**: Standard security with shorter retention
- **Networking**: Minimal networking components
- **Monitoring**: Basic monitoring without alerting
- **Cost**: Auto-shutdown enabled, minimal backup retention

### Test (test)
- **SKUs**: Standard tiers for realistic testing
- **Security**: Enhanced security with private endpoints
- **Networking**: Production-like networking setup
- **Monitoring**: Full monitoring with alerting
- **Cost**: Balanced cost optimization

### Production (prod)
- **SKUs**: Premium tiers for performance and availability
- **Security**: Maximum security with all features enabled
- **Networking**: Full networking stack with redundancy
- **Monitoring**: Comprehensive monitoring and alerting
- **Cost**: Long-term retention, no auto-shutdown

## Validation

The module includes validation rules for:
- Environment must be one of: dev, test, prod
- Project name must be ≤20 characters and alphanumeric with hyphens
- Tenant ID must exist in configurations if specified
- Compliance level must be: Standard, High, or Critical

## License

This module is part of the AIRCLOUD Azure Infrastructure Platform.

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id) | Action Group ID for alerts | `string` | `null` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_compliance_level"></a> [compliance\_level](#input\_compliance\_level) | Compliance level (Standard, High, Critical) | `string` | `"Standard"` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center for billing | `string` | `"IT"` | no |
| <a name="input_created_by"></a> [created\_by](#input\_created\_by) | Who created these resources | `string` | `"Terraform"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Custom DNS servers | `list(string)` | `[]` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable monitoring and alerting | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, test, prod) | `string` | n/a | yes |
| <a name="input_environment_overrides"></a> [environment\_overrides](#input\_environment\_overrides) | Override default environment configuration | <pre>object({<br/>    sku_defaults = optional(object({<br/>      vm_size             = optional(string)<br/>      storage_tier        = optional(string)<br/>      database_tier       = optional(string)<br/>      key_vault_sku       = optional(string)<br/>      application_gateway = optional(string)<br/>      firewall_sku        = optional(string)<br/>      vpn_gateway_sku     = optional(string)<br/>      container_registry  = optional(string)<br/>      api_management_sku  = optional(string)<br/>    }))<br/>    networking = optional(object({<br/>      enable_bastion             = optional(bool)<br/>      enable_firewall            = optional(bool)<br/>      enable_vpn_gateway         = optional(bool)<br/>      enable_application_gateway = optional(bool)<br/>      enable_private_endpoints   = optional(bool)<br/>      network_security_strict    = optional(bool)<br/>    }))<br/>    security = optional(object({<br/>      enable_soft_delete         = optional(bool)<br/>      purge_protection           = optional(bool)<br/>      enable_rbac                = optional(bool)<br/>      enable_private_endpoint    = optional(bool)<br/>      enable_diagnostic_settings = optional(bool)<br/>      retention_days             = optional(number)<br/>    }))<br/>    compliance = optional(object({<br/>      enable_policy_assignments = optional(bool)<br/>      enable_custom_policies    = optional(bool)<br/>      enable_monitoring         = optional(bool)<br/>      enable_alerting           = optional(bool)<br/>    }))<br/>    cost_optimization = optional(object({<br/>      auto_scaling_enabled      = optional(bool)<br/>      backup_retention_days     = optional(number)<br/>      log_retention_days        = optional(number)<br/>      enable_scheduled_shutdown = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_hub_virtual_network_id"></a> [hub\_virtual\_network\_id](#input\_hub\_virtual\_network\_id) | Hub Virtual Network ID for spoke connections | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Central Key Vault ID for secrets | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for resources | `string` | `"East US"` | no |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short location code (override if not in mapping) | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Managed Identity ID for resource access | `string` | `null` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Custom naming prefix (if not provided, will be generated from organization-project-environment) | `string` | `null` | no |
| <a name="input_naming_suffix"></a> [naming\_suffix](#input\_naming\_suffix) | Custom naming suffix (if not provided, will use location short code) | `string` | `null` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Organization name for resource naming | `string` | `"aircloud"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Resource owner | `string` | `"Platform Team"` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones for private endpoints | `map(string)` | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming and tagging | `string` | n/a | yes |
| <a name="input_recovery_services_vault_id"></a> [recovery\_services\_vault\_id](#input\_recovery\_services\_vault\_id) | Recovery Services Vault ID for backups | `string` | `null` | no |
| <a name="input_tenant_configurations"></a> [tenant\_configurations](#input\_tenant\_configurations) | Configuration for multiple tenants | <pre>map(object({<br/>    display_name = string<br/>    domain_name  = string<br/>    subscriptions = list(object({<br/>      subscription_id = string<br/>      name            = string<br/>      role            = string<br/>    }))<br/>    custom_settings = optional(object({<br/>      sku_defaults = optional(object({<br/>        vm_size             = optional(string)<br/>        storage_tier        = optional(string)<br/>        database_tier       = optional(string)<br/>        key_vault_sku       = optional(string)<br/>        application_gateway = optional(string)<br/>        firewall_sku        = optional(string)<br/>        vpn_gateway_sku     = optional(string)<br/>        container_registry  = optional(string)<br/>        api_management_sku  = optional(string)<br/>      }))<br/>      networking = optional(object({<br/>        enable_bastion             = optional(bool)<br/>        enable_firewall            = optional(bool)<br/>        enable_vpn_gateway         = optional(bool)<br/>        enable_application_gateway = optional(bool)<br/>        enable_private_endpoints   = optional(bool)<br/>        network_security_strict    = optional(bool)<br/>      }))<br/>      security = optional(object({<br/>        enable_soft_delete         = optional(bool)<br/>        purge_protection           = optional(bool)<br/>        enable_rbac                = optional(bool)<br/>        enable_private_endpoint    = optional(bool)<br/>        enable_diagnostic_settings = optional(bool)<br/>        retention_days             = optional(number)<br/>      }))<br/>      compliance = optional(object({<br/>        enable_policy_assignments = optional(bool)<br/>        enable_custom_policies    = optional(bool)<br/>        enable_monitoring         = optional(bool)<br/>        enable_alerting           = optional(bool)<br/>      }))<br/>      cost_optimization = optional(object({<br/>        auto_scaling_enabled      = optional(bool)<br/>        backup_retention_days     = optional(number)<br/>        log_retention_days        = optional(number)<br/>        enable_scheduled_shutdown = optional(bool)<br/>      }))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Current tenant ID (optional for single-tenant deployments) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_tenant_configs"></a> [all\_tenant\_configs](#output\_all\_tenant\_configs) | All tenant configurations (for multi-tenant deployments) |
| <a name="output_client_config"></a> [client\_config](#output\_client\_config) | Current client configuration |
| <a name="output_common_tags"></a> [common\_tags](#output\_common\_tags) | Common tags to be applied to all resources |
| <a name="output_compliance_defaults"></a> [compliance\_defaults](#output\_compliance\_defaults) | Compliance defaults for current environment |
| <a name="output_cost_optimization_defaults"></a> [cost\_optimization\_defaults](#output\_cost\_optimization\_defaults) | Cost optimization defaults for current environment |
| <a name="output_current_env_config"></a> [current\_env\_config](#output\_current\_env\_config) | Current environment configuration with overrides applied |
| <a name="output_current_tenant_config"></a> [current\_tenant\_config](#output\_current\_tenant\_config) | Current tenant configuration |
| <a name="output_environment"></a> [environment](#output\_environment) | Current environment |
| <a name="output_is_multi_tenant"></a> [is\_multi\_tenant](#output\_is\_multi\_tenant) | Whether this is a multi-tenant deployment |
| <a name="output_location"></a> [location](#output\_location) | Azure location |
| <a name="output_location_short"></a> [location\_short](#output\_location\_short) | Short location code |
| <a name="output_naming_convention"></a> [naming\_convention](#output\_naming\_convention) | Naming convention patterns |
| <a name="output_naming_prefix"></a> [naming\_prefix](#output\_naming\_prefix) | Naming prefix |
| <a name="output_naming_suffix"></a> [naming\_suffix](#output\_naming\_suffix) | Naming suffix |
| <a name="output_networking_defaults"></a> [networking\_defaults](#output\_networking\_defaults) | Networking defaults for current environment |
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | Standard resource names based on naming convention |
| <a name="output_security_defaults"></a> [security\_defaults](#output\_security\_defaults) | Security defaults for current environment |
| <a name="output_should_create_application_gateway"></a> [should\_create\_application\_gateway](#output\_should\_create\_application\_gateway) | Whether to create Application Gateway |
| <a name="output_should_create_bastion"></a> [should\_create\_bastion](#output\_should\_create\_bastion) | Whether to create Bastion Host |
| <a name="output_should_create_firewall"></a> [should\_create\_firewall](#output\_should\_create\_firewall) | Whether to create Azure Firewall |
| <a name="output_should_create_vpn_gateway"></a> [should\_create\_vpn\_gateway](#output\_should\_create\_vpn\_gateway) | Whether to create VPN Gateway |
| <a name="output_should_enable_alerting"></a> [should\_enable\_alerting](#output\_should\_enable\_alerting) | Whether to enable alerting |
| <a name="output_should_enable_custom_policies"></a> [should\_enable\_custom\_policies](#output\_should\_enable\_custom\_policies) | Whether to enable custom policies |
| <a name="output_should_enable_monitoring"></a> [should\_enable\_monitoring](#output\_should\_enable\_monitoring) | Whether to enable monitoring |
| <a name="output_should_enable_policy_assignments"></a> [should\_enable\_policy\_assignments](#output\_should\_enable\_policy\_assignments) | Whether to enable policy assignments |
| <a name="output_should_enable_private_endpoints"></a> [should\_enable\_private\_endpoints](#output\_should\_enable\_private\_endpoints) | Whether to enable private endpoints |
| <a name="output_sku_defaults"></a> [sku\_defaults](#output\_sku\_defaults) | SKU defaults for current environment |
| <a name="output_subscription_display_name"></a> [subscription\_display\_name](#output\_subscription\_display\_name) | Current subscription display name |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Current subscription ID |
| <a name="output_tenant_count"></a> [tenant\_count](#output\_tenant\_count) | Number of configured tenants |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Current tenant ID |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
