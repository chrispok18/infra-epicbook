# -----------------------------------------------------------------------------
# outputs.tf — the 4 NON-sensitive values handed to the Application Repository
# (plus the resource group name for convenience). No passwords here.
# -----------------------------------------------------------------------------

output "app_public_ip" {
  description = "Frontend VM public IP — open http://<this IP> in the browser"
  value       = azurerm_public_ip.frontend.ip_address
}

output "backend_ansible_host" {
  description = "Address Ansible uses to SSH into the backend VM (SSH locked to admin IPs)"
  value       = azurerm_public_ip.backend.ip_address
}

output "backend_private_ip" {
  description = "Backend private IP — Nginx on the frontend proxies to this address"
  value       = azurerm_network_interface.backend.private_ip_address
}

output "mysql_fqdn" {
  description = "Private DNS name of the MySQL server (resolvable only inside the VNet)"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
