# -----------------------------------------------------------------------------
# database.tf — PRIVATE Azure Database for MySQL Flexible Server
# No public endpoint: it lives inside the delegated db subnet and is found
# through a private DNS zone that only this VNet can see.
# -----------------------------------------------------------------------------

# Server names must be unique across ALL of Azure, so we add a random suffix.
resource "random_string" "mysql_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.prefix}.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.prefix}-mysql-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.tags
}

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.prefix}-mysql-${random_string.mysql_suffix.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "8.0.21"
  sku_name               = var.mysql_sku
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  # Private access (VNet integration) — no public network access at all
  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  backup_retention_days = 1

  storage {
    size_gb = 20
  }

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]

  lifecycle {
    # Azure picks an availability zone itself; don't try to "fix" it on later runs
    ignore_changes = [zone]
  }
}

# EpicBook's Node driver (Sequelize/mysql2) connects without TLS by default.
# Traffic never leaves the private VNet, so TLS enforcement is turned off here.
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_database" "bookstore" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
