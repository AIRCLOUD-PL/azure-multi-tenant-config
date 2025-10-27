# Multi-Tenant Configuration Module

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

### Basic Usage (Single Tenant)

```hcl
module "config" {
  source = "./modules/multi-tenant-config"
  
  environment    = "prod"
  location       = "East US"
  project_name   = "myproject"
  organization   = "myorg"
  created_by     = "Platform Team"
  cost_center    = "IT-001"
}

# Use the configuration in other modules
module "key_vault" {
  source = "./repos/azure-key-vault-module"
  
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
  source = "./modules/multi-tenant-config"
  
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
  source = "./modules/multi-tenant-config"
  
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

## Outputs

The module provides numerous outputs for use in other modules:

- `current_env_config`: Complete environment configuration
- `resource_names`: Standardized resource names
- `common_tags`: Standard tags for all resources
- `sku_defaults`: Environment-appropriate SKUs
- `security_defaults`: Security configuration
- `should_create_*`: Boolean flags for conditional resource creation

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 3.80.0, < 5.0.0 |
| null | >= 3.0.0 |

## Validation

The module includes validation rules for:
- Environment must be one of: dev, test, prod
- Project name must be ≤20 characters and alphanumeric with hyphens
- Tenant ID must exist in configurations if specified
- Compliance level must be: Standard, High, or Critical

## License

This module is part of the AIRCLOUD Azure Infrastructure Platform.
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
