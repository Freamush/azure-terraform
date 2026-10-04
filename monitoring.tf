resource "azurerm_log_analytics_workspace" "log_space" {
  name                = "azure-log-analytics"
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
  tags                = local.tags

}

resource "azurerm_monitor_diagnostic_setting" "fw-diagnostics" {
  name                           = "firewall-diagnostics"
  target_resource_id             = azurerm_firewall.az-firewall.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.log_space.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AZFWNetworkRule"
  }

  enabled_log {
    category = "AZFWDnsQuery"
  }

  enabled_log {
    category = "AZFWThreatIntel"
  }

  enabled_log {
    category = "AZFWApplicationRule"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage-diagnostics" {
  name                       = "storage-diagnostics"
  target_resource_id         = "${azurerm_storage_account.slzstorageiac.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_space.id

  enabled_log {
    category = "StorageDelete"
  }
  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }


}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "action_group"
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  short_name          = "AG-1"
  email_receiver {
    name          = var.username
    email_address = var.ALERT_EMAIL
  }
  tags = local.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert1" {
  name                 = "deny_alert"
  location             = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name  = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  scopes               = [azurerm_log_analytics_workspace.log_space.id]
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  criteria {
    query                   = <<-QUERY
      AZFWApplicationRule
      | where Action == "Deny"
      | summarize DenyCount = count() by SourceIp
      | where DenyCount > 3
      QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }
  action {
    action_groups = [azurerm_monitor_action_group.action_group.id]
  }
  tags = local.tags

}