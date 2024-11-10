location        = "West US"
vm_size         = "Standard_B2s_v2"
admin_username  = "azureuser"
ssh_public_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmojX+6Hp5qQMEJ3MWmIVwh/s6XYqghxyXsMcsb66j0 generated-by-azure"
disk_size_gb    = 30
image_reference = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}