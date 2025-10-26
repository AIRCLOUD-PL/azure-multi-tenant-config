# Multi-Tenant Configuration Variables

# Core Environment Configuration
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod"
  }
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "East US"
}

variable "location_short" {
  description = "Short location code (override if not in mapping)"
  type        = string
  default     = null
}

# Multi-Tenant Configuration
variable "tenant_id" {
  description = "Current tenant ID (optional for single-tenant deployments)"
  type        = string
  default     = null
}

variable "tenant_configurations" {
  description = "Configuration for multiple tenants"
  type = map(object({
    display_name = string
    domain_name  = string
    subscriptions = list(object({
      subscription_id = string
      name            = string
      role            = string
    }))
    custom_settings = optional(object({
      sku_defaults = optional(object({
        vm_size             = optional(string)
        storage_tier        = optional(string)
        database_tier       = optional(string)
        key_vault_sku       = optional(string)
        application_gateway = optional(string)
        firewall_sku        = optional(string)
        vpn_gateway_sku     = optional(string)
        container_registry  = optional(string)
        api_management_sku  = optional(string)
      }))
      networking = optional(object({
        enable_bastion             = optional(bool)
        enable_firewall            = optional(bool)
        enable_vpn_gateway         = optional(bool)
        enable_application_gateway = optional(bool)
        enable_private_endpoints   = optional(bool)
        network_security_strict    = optional(bool)
      }))
      security = optional(object({
        enable_soft_delete         = optional(bool)
        purge_protection           = optional(bool)
        enable_rbac                = optional(bool)
        enable_private_endpoint    = optional(bool)
        enable_diagnostic_settings = optional(bool)
        retention_days             = optional(number)
      }))
      compliance = optional(object({
        enable_policy_assignments = optional(bool)
        enable_custom_policies    = optional(bool)
        enable_monitoring         = optional(bool)
        enable_alerting           = optional(bool)
      }))
      cost_optimization = optional(object({
        auto_scaling_enabled      = optional(bool)
        backup_retention_days     = optional(number)
        log_retention_days        = optional(number)
        enable_scheduled_shutdown = optional(bool)
      }))
    }))
  }))
  default = {}
}

# Environment Overrides
variable "environment_overrides" {
  description = "Override default environment configuration"
  type = object({
    sku_defaults = optional(object({
      vm_size             = optional(string)
      storage_tier        = optional(string)
      database_tier       = optional(string)
      key_vault_sku       = optional(string)
      application_gateway = optional(string)
      firewall_sku        = optional(string)
      vpn_gateway_sku     = optional(string)
      container_registry  = optional(string)
      api_management_sku  = optional(string)
    }))
    networking = optional(object({
      enable_bastion             = optional(bool)
      enable_firewall            = optional(bool)
      enable_vpn_gateway         = optional(bool)
      enable_application_gateway = optional(bool)
      enable_private_endpoints   = optional(bool)
      network_security_strict    = optional(bool)
    }))
    security = optional(object({
      enable_soft_delete         = optional(bool)
      purge_protection           = optional(bool)
      enable_rbac                = optional(bool)
      enable_private_endpoint    = optional(bool)
      enable_diagnostic_settings = optional(bool)
      retention_days             = optional(number)
    }))
    compliance = optional(object({
      enable_policy_assignments = optional(bool)
      enable_custom_policies    = optional(bool)
      enable_monitoring         = optional(bool)
      enable_alerting           = optional(bool)
    }))
    cost_optimization = optional(object({
      auto_scaling_enabled      = optional(bool)
      backup_retention_days     = optional(number)
      log_retention_days        = optional(number)
      enable_scheduled_shutdown = optional(bool)
    }))
  })
  default = null
}

# Organization and Project Information
variable "organization" {
  description = "Organization name for resource naming"
  type        = string
  default     = "aircloud"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  validation {
    condition     = length(var.project_name) <= 20 && can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must be 20 characters or less and contain only alphanumeric characters and hyphens"
  }
}

variable "created_by" {
  description = "Who created these resources"
  type        = string
  default     = "Terraform"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "Platform Team"
}

variable "compliance_level" {
  description = "Compliance level (Standard, High, Critical)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "High", "Critical"], var.compliance_level)
    error_message = "Compliance level must be one of: Standard, High, Critical"
  }
}

# Naming Convention
variable "naming_prefix" {
  description = "Custom naming prefix (if not provided, will be generated from organization-project-environment)"
  type        = string
  default     = null
}

variable "naming_suffix" {
  description = "Custom naming suffix (if not provided, will use location short code)"
  type        = string
  default     = null
}

# Additional Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Log Analytics Workspace (for monitoring and diagnostics)
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = null
}

# Network Configuration
variable "hub_virtual_network_id" {
  description = "Hub Virtual Network ID for spoke connections"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

# Security Configuration
variable "key_vault_id" {
  description = "Central Key Vault ID for secrets"
  type        = string
  default     = null
}

variable "managed_identity_id" {
  description = "Managed Identity ID for resource access"
  type        = string
  default     = null
}

# Monitoring and Alerting
variable "action_group_id" {
  description = "Action Group ID for alerts"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

# Backup and Recovery
variable "recovery_services_vault_id" {
  description = "Recovery Services Vault ID for backups"
  type        = string
  default     = null
}

# Private DNS Zones (for private endpoints)
variable "private_dns_zones" {
  description = "Private DNS Zones for private endpoints"
  type        = map(string)
  default     = {}
}