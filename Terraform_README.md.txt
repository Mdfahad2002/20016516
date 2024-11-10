Azure Infrastructure Terraform Repository

This repository contains Terraform scripts for automating the setup of cloud infrastructure required to host a server instance in Azure. The scripts provision an Azure Virtual Machine and configure necessary resources such as network security groups, virtual networks, and other networking components.

 Prerequisites
- Terraform installed on your local machine
- An Azure subscription
- Azure CLI installed and configured
- Service Principal with necessary permissions

 Directory Structure

??? main.tf            # Main Terraform configuration file
??? variables.tf       # Variables used in Terraform configurations
??? outputs.tf         # Output definitions
??? terraform.tfvars   # Values for the defined variables
??? README.md         # Repository documentation


Getting Started

 1. Clone the Repository

git clone https://github.com/yourusername/your-repo.git
cd your-repo

2. Configure Azure Credentials
Log in to Azure using the Azure CLI:
az login

Create a Service Principal (if not already created):
az ad sp create-for-rbac --name "TerraformSP" --role Contributor

 3. Create Configuration Files
 main.tf:

 Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
 Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

 Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

 Create a public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
Create a network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

 Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

 Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

Create a virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                           = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


 variables.tf:

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "myapp"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}
variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
}
 outputs.tf:

output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "virtual_machine_name" {
  value = azurerm_linux_virtual_machine.vm.name
}
 terraform.tfvars:

prefix              = "myapp"
resource_group_name = "myapp-rg"
location           = "eastus"
vm_size            = "Standard_B1s"
admin_username     = "azureuser"
ssh_public_key_path = "~/.ssh/id_rsa.pub"



Deployment Steps

 1. Initialize Terraform
Initialize the Terraform configuration to download required providers:
terraform init
 2. Plan the Deployment
Create an execution plan to preview the changes:
terraform plan
 3. Apply the Configuration
Create the resources defined in the Terraform configuration:
terraform apply
Type `yes` when prompted to confirm the action.
 4. Access the VM
After deployment, you can access the VM using SSH:
ssh azureuser@<public_ip_address>
Replace `<public_ip_address>` with the value from the terraform output.
 5. Clean Up
To destroy the resources created by Terraform:
terraform destroy
Type `yes` when prompted to confirm the action.

 Notes
- Ensure you have the necessary permissions in your Azure subscription to create and manage the resources defined in the Terraform scripts.
- The network security group is configured to allow SSH access (port 22) by default. Modify the security rules in `main.tf` based on your application's requirements.
- Remember to keep your Azure credentials and SSH keys secure and never commit them to version control.
- Consider using Azure Key Vault for storing sensitive information in a production environment.
