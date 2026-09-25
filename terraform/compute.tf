# -----------------------------------------------------------------------------
# compute.tf — the two Ubuntu VMs (frontend = Nginx, backend = EpicBook app)
# -----------------------------------------------------------------------------

locals {
  ssh_public_key = file("${path.module}/${var.ssh_public_key_path}")

  # Ubuntu 22.04 LTS (Generation 1 image — works on every VM size incl. Dv2 Promo)
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# --- Public IPs ---------------------------------------------------------------
# Frontend: serves the website on port 80.
# Backend: used ONLY for Ansible SSH (locked to admin IPs by the NSG) and for
#          outbound internet (apt/npm). Its app port is NOT reachable publicly.

resource "azurerm_public_ip" "frontend" {
  name                = "${var.prefix}-frontend-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "backend" {
  name                = "${var.prefix}-backend-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# --- Network cards --------------------------------------------------------------

resource "azurerm_network_interface" "frontend" {
  name                = "${var.prefix}-frontend-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend.id
  }
}

resource "azurerm_network_interface" "backend" {
  name                = "${var.prefix}-backend-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend.id
  }
}

# --- Virtual machines -----------------------------------------------------------

resource "azurerm_linux_virtual_machine" "frontend" {
  name                            = "${var.prefix}-frontend-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.frontend.id]
  tags                            = merge(var.tags, { role = "frontend" })

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  os_disk {
    name                 = "${var.prefix}-frontend-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS" # Dv2 (non-"s") sizes can't use Premium disks
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                            = "${var.prefix}-backend-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.backend.id]
  tags                            = merge(var.tags, { role = "backend" })

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  os_disk {
    name                 = "${var.prefix}-backend-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}
