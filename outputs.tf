# Multi-Tenant Configuration Outputs

# Environment Configuration
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "current_env_config" {
  description = "Current environment configuration with overrides applied"
  value       = local.current_env_config
}

output "location" {
  description = "Azure location"
  value       = var.location
}

output "location_short" {
  description = "Short location code"
  value       = local.location_short
}

# Tenant Configuration
output "tenant_id" {
  description = "Current tenant ID"
  value       = var.tenant_id
}

output "current_tenant_config" {
  description = "Current tenant configuration"
  value       = local.current_tenant_config
}

output "subscription_id" {
  description = "Current subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "subscription_display_name" {
  description = "Current subscription display name"
  value       = data.azurerm_subscription.current.display_name
}

# Naming Convention
output "naming_convention" {
  description = "Naming convention patterns"
  value       = local.naming_convention
}

output "naming_prefix" {
  description = "Naming prefix"
  value       = local.naming_convention.prefix
}

output "naming_suffix" {
  description = "Naming suffix"
  value       = local.naming_convention.suffix
}

# Resource Names (commonly used patterns)
output "resource_names" {
  description = "Standard resource names based on naming convention"
  value       = local.naming_convention.patterns
}

# Tags
output "common_tags" {
  description = "Common tags to be applied to all resources"
  value       = local.common_tags
}

# Environment-specific defaults
output "sku_defaults" {
  description = "SKU defaults for current environment"
  value       = local.current_env_config.sku_defaults
}

output "networking_defaults" {
  description = "Networking defaults for current environment"
  value       = local.current_env_config.networking
}

output "security_defaults" {
  description = "Security defaults for current environment"
  value       = local.current_env_config.security
}

output "compliance_defaults" {
  description = "Compliance defaults for current environment"
  value       = local.current_env_config.compliance
}

output "cost_optimization_defaults" {
  description = "Cost optimization defaults for current environment"
  value       = local.current_env_config.cost_optimization
}

# Helper outputs for conditional resource creation
output "should_create_bastion" {
  description = "Whether to create Bastion Host"
  value       = local.current_env_config.networking.enable_bastion
}

output "should_create_firewall" {
  description = "Whether to create Azure Firewall"
  value       = local.current_env_config.networking.enable_firewall
}

output "should_create_vpn_gateway" {
  description = "Whether to create VPN Gateway"
  value       = local.current_env_config.networking.enable_vpn_gateway
}

output "should_create_application_gateway" {
  description = "Whether to create Application Gateway"
  value       = local.current_env_config.networking.enable_application_gateway
}

output "should_enable_private_endpoints" {
  description = "Whether to enable private endpoints"
  value       = local.current_env_config.networking.enable_private_endpoints
}

output "should_enable_policy_assignments" {
  description = "Whether to enable policy assignments"
  value       = local.current_env_config.compliance.enable_policy_assignments
}

output "should_enable_custom_policies" {
  description = "Whether to enable custom policies"
  value       = local.current_env_config.compliance.enable_custom_policies
}

output "should_enable_monitoring" {
  description = "Whether to enable monitoring"
  value       = local.current_env_config.compliance.enable_monitoring
}

output "should_enable_alerting" {
  description = "Whether to enable alerting"
  value       = local.current_env_config.compliance.enable_alerting
}

# Context information
output "client_config" {
  description = "Current client configuration"
  value = {
    client_id       = data.azurerm_client_config.current.client_id
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id
    object_id       = data.azurerm_client_config.current.object_id
  }
}

# Multi-tenant helper outputs
output "all_tenant_configs" {
  description = "All tenant configurations (for multi-tenant deployments)"
  value       = local.tenant_configs
}

output "is_multi_tenant" {
  description = "Whether this is a multi-tenant deployment"
  value       = length(var.tenant_configurations) > 1
}

output "tenant_count" {
  description = "Number of configured tenants"
  value       = length(var.tenant_configurations)
}