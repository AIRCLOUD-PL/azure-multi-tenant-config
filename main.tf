# Multi-Tenant and Multi-Subscription Configuration Module
# This module provides centralized configuration for different environments
# across multiple tenants and subscriptions

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0, < 5.0.0"
    }
  }
}

# Data sources for current context
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Environment-specific defaults based on best practices
locals {
  # Environment configuration matrix
  environment_configs = {
    dev = {
      sku_defaults = {
        vm_size             = "Standard_B2s"
        storage_tier        = "Standard"
        database_tier       = "Basic"
        key_vault_sku       = "standard"
        application_gateway = "Standard_v2"
        firewall_sku        = "Standard"
        vpn_gateway_sku     = "VpnGw1"
        container_registry  = "Basic"
        api_management_sku  = "Developer"
      }
      networking = {
        enable_bastion             = false
        enable_firewall            = false
        enable_vpn_gateway         = false
        enable_application_gateway = false
        enable_private_endpoints   = false
        network_security_strict    = false
      }
      security = {
        enable_soft_delete         = true
        purge_protection           = false
        enable_rbac                = true
        enable_private_endpoint    = false
        enable_diagnostic_settings = true
        retention_days             = 30
      }
      compliance = {
        enable_policy_assignments = false
        enable_custom_policies    = false
        enable_monitoring         = true
        enable_alerting           = false
      }
      cost_optimization = {
        auto_scaling_enabled      = false
        backup_retention_days     = 7
        log_retention_days        = 30
        enable_scheduled_shutdown = true
      }
    }

    test = {
      sku_defaults = {
        vm_size             = "Standard_D2s_v3"
        storage_tier        = "Standard"
        database_tier       = "Standard"
        key_vault_sku       = "standard"
        application_gateway = "Standard_v2"
        firewall_sku        = "Standard"
        vpn_gateway_sku     = "VpnGw1"
        container_registry  = "Standard"
        api_management_sku  = "Standard"
      }
      networking = {
        enable_bastion             = true
        enable_firewall            = false
        enable_vpn_gateway         = false
        enable_application_gateway = true
        enable_private_endpoints   = true
        network_security_strict    = true
      }
      security = {
        enable_soft_delete         = true
        purge_protection           = false
        enable_rbac                = true
        enable_private_endpoint    = true
        enable_diagnostic_settings = true
        retention_days             = 90
      }
      compliance = {
        enable_policy_assignments = true
        enable_custom_policies    = false
        enable_monitoring         = true
        enable_alerting           = true
      }
      cost_optimization = {
        auto_scaling_enabled      = true
        backup_retention_days     = 30
        log_retention_days        = 90
        enable_scheduled_shutdown = false
      }
    }

    prod = {
      sku_defaults = {
        vm_size             = "Standard_D4s_v3"
        storage_tier        = "Premium"
        database_tier       = "Premium"
        key_vault_sku       = "premium"
        application_gateway = "WAF_v2"
        firewall_sku        = "Premium"
        vpn_gateway_sku     = "VpnGw3AZ"
        container_registry  = "Premium"
        api_management_sku  = "Premium"
      }
      networking = {
        enable_bastion             = true
        enable_firewall            = true
        enable_vpn_gateway         = true
        enable_application_gateway = true
        enable_private_endpoints   = true
        network_security_strict    = true
      }
      security = {
        enable_soft_delete         = true
        purge_protection           = true
        enable_rbac                = true
        enable_private_endpoint    = true
        enable_diagnostic_settings = true
        retention_days             = 365
      }
      compliance = {
        enable_policy_assignments = true
        enable_custom_policies    = true
        enable_monitoring         = true
        enable_alerting           = true
      }
      cost_optimization = {
        auto_scaling_enabled      = true
        backup_retention_days     = 365
        log_retention_days        = 365
        enable_scheduled_shutdown = false
      }
    }
  }

  # Multi-tenant configuration
  tenant_configs = {
    for tenant_id, config in var.tenant_configurations : tenant_id => merge(
      {
        display_name  = config.display_name
        domain_name   = config.domain_name
        subscriptions = config.subscriptions
      },
      config.custom_settings != null ? config.custom_settings : {}
    )
  }

  # Current environment configuration with overrides
  current_env_config = merge(
    local.environment_configs[var.environment],
    var.environment_overrides != null ? var.environment_overrides : {}
  )

  # Current tenant configuration
  current_tenant_config = var.tenant_id != null ? local.tenant_configs[var.tenant_id] : null

  # Common tags that will be applied to all resources
  common_tags = merge(
    {
      Environment    = var.environment
      TenantId       = var.tenant_id
      SubscriptionId = data.azurerm_subscription.current.subscription_id
      ManagedBy      = "Terraform"
      CreatedBy      = var.created_by
      Project        = var.project_name
      CostCenter     = var.cost_center
      Owner          = var.owner
      Compliance     = var.compliance_level
    },
    var.additional_tags
  )

  # Resource naming convention
  naming_convention = {
    prefix = var.naming_prefix != null ? var.naming_prefix : lower("${var.organization}-${var.project_name}-${var.environment}")
    suffix = var.naming_suffix != null ? var.naming_suffix : lower("${var.location_short}")

    # Standard naming patterns
    patterns = {
      resource_group      = "${local.naming_convention.prefix}-rg-${local.naming_convention.suffix}"
      storage_account     = lower(replace("${local.naming_convention.prefix}st${local.naming_convention.suffix}", "-", ""))
      key_vault           = "${local.naming_convention.prefix}-kv-${local.naming_convention.suffix}"
      virtual_network     = "${local.naming_convention.prefix}-vnet-${local.naming_convention.suffix}"
      subnet              = "${local.naming_convention.prefix}-snet-{purpose}-${local.naming_convention.suffix}"
      nsg                 = "${local.naming_convention.prefix}-nsg-{purpose}-${local.naming_convention.suffix}"
      vm                  = "${local.naming_convention.prefix}-vm-{purpose}-${local.naming_convention.suffix}"
      container_registry  = lower(replace("${local.naming_convention.prefix}cr${local.naming_convention.suffix}", "-", ""))
      api_management      = "${local.naming_convention.prefix}-apim-${local.naming_convention.suffix}"
      application_gateway = "${local.naming_convention.prefix}-agw-${local.naming_convention.suffix}"
      firewall            = "${local.naming_convention.prefix}-fw-${local.naming_convention.suffix}"
      vpn_gateway         = "${local.naming_convention.prefix}-vpngw-${local.naming_convention.suffix}"
    }
  }

  # Location mappings
  location_mappings = {
    "East US"              = "eus"
    "East US 2"            = "eus2"
    "West US"              = "wus"
    "West US 2"            = "wus2"
    "West US 3"            = "wus3"
    "Central US"           = "cus"
    "North Central US"     = "ncus"
    "South Central US"     = "scus"
    "West Central US"      = "wcus"
    "Canada Central"       = "cac"
    "Canada East"          = "cae"
    "Brazil South"         = "brs"
    "North Europe"         = "neu"
    "West Europe"          = "weu"
    "UK South"             = "uks"
    "UK West"              = "ukw"
    "France Central"       = "frc"
    "France South"         = "frs"
    "Germany West Central" = "gwc"
    "Germany North"        = "gn"
    "Switzerland North"    = "swn"
    "Switzerland West"     = "sww"
    "Norway East"          = "noe"
    "Norway West"          = "now"
    "Southeast Asia"       = "sea"
    "East Asia"            = "ea"
    "Australia East"       = "aue"
    "Australia Southeast"  = "aus"
    "Australia Central"    = "auc"
    "Japan East"           = "jpe"
    "Japan West"           = "jpw"
    "Korea Central"        = "krc"
    "Korea South"          = "krs"
    "India Central"        = "inc"
    "India South"          = "ins"
    "India West"           = "inw"
    "UAE North"            = "uan"
    "UAE Central"          = "uac"
    "South Africa North"   = "san"
    "South Africa West"    = "saw"
  }

  location_short = lookup(local.location_mappings, var.location, "unk")
}

# Validation rules
resource "null_resource" "validation" {
  lifecycle {
    precondition {
      condition     = contains(["dev", "test", "prod"], var.environment)
      error_message = "Environment must be one of: dev, test, prod"
    }

    precondition {
      condition     = var.tenant_id == null || contains(keys(var.tenant_configurations), var.tenant_id)
      error_message = "If tenant_id is specified, it must exist in tenant_configurations"
    }

    precondition {
      condition     = length(var.project_name) <= 20 && can(regex("^[a-zA-Z0-9-]+$", var.project_name))
      error_message = "Project name must be 20 characters or less and contain only alphanumeric characters and hyphens"
    }
  }
}