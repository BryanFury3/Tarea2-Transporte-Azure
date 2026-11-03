terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "64ba6270-4ff9-49bd-becc-ea814f7d10c9" 
  client_id       = "dbda520d-f903-4fe9-a43f-26760b892ae3"
  client_secret   = "DeZ8Q~i0l8ZO_RbPeUXUXr9444bSaXh~~vMVla~y"
  tenant_id       = "cc28633f-12b8-46cb-bc15-951dae239b4d"
}

resource "azurerm_resource_group" "grupo_1" {
  name     = "rg-ucb-sistelecom-prod"
  location = "East US"
}

resource "azurerm_resource_group" "grupo_2" {
  name     = "rg-ucb-sistelecom-dev"
  location = "East US"
}


resource "azurerm_storage_account" "storage_dev" {
  name                     = "stucbsistelecomraw" 
  resource_group_name      = azurerm_resource_group.grupo_2.name
  location                 = azurerm_resource_group.grupo_2.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container_raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.storage_dev.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "adf_dev" {
  name                = "adf-ucb-transporte-dev"
  location            = azurerm_resource_group.grupo_2.location
  resource_group_name = azurerm_resource_group.grupo_2.name
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sql-ucb-sistelecom-dev-v3"
  resource_group_name          = azurerm_resource_group.grupo_2.name
  location                     = "Brazil South"
  version                      = "12.0"
  administrator_login          = "adminucb"
  administrator_login_password = "PasswordComplejo1234!"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "erp_transporte_db"
  server_id = azurerm_mssql_server.sqlserver.id
}

resource "azurerm_mssql_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}