terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "tbstoragemagi"
    container_name       = "tbcontainermagi"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "1958f27d-9fb5-4dfb-a702-bb2cf86b6af3"
}



resource "random_integer" "randoom" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "azureRG" {
  name     = "${var.resource_group_name}_${random_integer.randoom.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "servicePlan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.azureRG.name
  location            = azurerm_resource_group.azureRG.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "linuxWebApp" {
  name                = "${var.app_service_name}${random_integer.randoom.result}"
  resource_group_name = azurerm_resource_group.azureRG.name
  location            = azurerm_service_plan.servicePlan.location
  service_plan_id     = azurerm_service_plan.servicePlan.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.linuxWebApp.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}-${random_integer.randoom.result}"
  resource_group_name          = azurerm_resource_group.azureRG.name
  location                     = azurerm_resource_group.azureRG.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_pasword
}

resource "azurerm_mssql_database" "database" {
  name           = "${var.sql_server_db_name}-${random_integer.randoom.result}"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}


resource "azurerm_mssql_firewall_rule" "firewall" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}