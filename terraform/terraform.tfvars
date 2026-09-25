# -----------------------------------------------------------------------------
# terraform.tfvars — NON-sensitive settings only (safe to commit).
# The MySQL password is NOT here: it comes from the pipeline secret variable.
# -----------------------------------------------------------------------------

prefix   = "epicbook"
location = "austriaeast"
vm_size  = "Standard_D2_v2_Promo"

# Only these IPs may SSH into the VMs:
#   51.20.182.27  = self-hosted Azure DevOps agent (AWS VM, do NOT stop it)
#   154.160.16.44 = Christian's home IP (update if it changes)
admin_ssh_cidrs = [
  "51.20.182.27/32",
  "154.160.16.44/32",
]
