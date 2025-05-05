terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.ade_subscription
  features {}
}

locals {
  tags = merge(var.tags,
  { Environment = var.ade_environment_type })
}

# Log Analytics workspace for container app monitoring
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.ade_env_name}-law"
  resource_group_name = var.resource_group_name
  location            = var.ade_location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.ade_env_name}-env"
  resource_group_name        = var.resource_group_name
  location                   = var.ade_location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = local.tags
}

# Container App
resource "azurerm_container_app" "app" {
  name                         = "${var.ade_env_name}-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = local.tags

  template {
    container {
      name   = "lob-app"
      image  = "globalazure2025nz-crbne5f9a2cufug9.azurecr.io/lob-app:${var.app_version}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ENV_NAME"
        value = var.ade_env_name
      }

      env {
        name  = "ENV_TYPE"
        value = var.ade_environment_type
      }

      env {
        name  = "GREETING"
        value = var.greeting
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = "globalazure2025nz-crbne5f9a2cufug9.azurecr.io"
    identity = "/subscriptions/0d661c82-f99b-46f9-bcc2-3dbaf5f3e7aa/resourceGroups/Global-Azure-Bootcamp/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Global-Azure-Bootcamp"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/0d661c82-f99b-46f9-bcc2-3dbaf5f3e7aa/resourceGroups/Global-Azure-Bootcamp/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Global-Azure-Bootcamp"]
  }
}

# Output the Container App URL
output "application_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
