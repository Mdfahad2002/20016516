variable "location" {
  description = "The Azure region in which resources will be created"
  type        = string
  default     = "West US"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "The SSH public key for VM login"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of the OS disk"
  type        = number
  default     = 30
}

variable "image_reference" {
  description = "The image to use for the virtual machine"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}