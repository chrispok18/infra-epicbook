# -----------------------------------------------------------------------------
# variables.tf — the "settings" of the infrastructure
# Non-sensitive values are set in terraform.tfvars.
# The MySQL password is NEVER set in a file: it arrives as TF_VAR_mysql_admin_password
# from the Azure DevOps secret variable group.
# -----------------------------------------------------------------------------

variable "prefix" {
  description = "Short name used at the start of every resource name"
  type        = string
  default     = "epicbook"
}

variable "location" {
  description = "Azure region (Azure for Students only allows a few European regions)"
  type        = string
  default     = "austriaeast"
}

variable "vm_size" {
  description = "VM size for both frontend and backend (must have quota on the subscription)"
  type        = string
  default     = "Standard_D2_v2_Promo"
}

variable "admin_username" {
  description = "Linux admin user created on both VMs (Ansible logs in as this user)"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path (relative to this folder) of the PUBLIC SSH key placed on both VMs"
  type        = string
  default     = "epicbook-azure-key.pub"
}

variable "admin_ssh_cidrs" {
  description = "The ONLY source IPs allowed to SSH (port 22) into the VMs: pipeline agent + your home IP"
  type        = list(string)
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "frontend_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "backend_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "backend_app_port" {
  description = "Port EpicBook (Node.js) listens on inside the backend VM"
  type        = number
  default     = 8080
}

variable "mysql_admin_username" {
  description = "MySQL admin user (comes from the pipeline variable group)"
  type        = string
  default     = "epicbookadmin"
}

variable "mysql_admin_password" {
  description = "MySQL admin password (comes ONLY from the secret pipeline variable)"
  type        = string
  sensitive   = true
}

variable "mysql_sku" {
  description = "Cheapest Burstable tier"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_database_name" {
  type    = string
  default = "bookstore"
}

variable "tags" {
  type = map(string)
  default = {
    project = "epicbook"
    owner   = "Christian Aryee"
    managed = "terraform"
  }
}
