# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURAAOO DO PROVEDOR AZURE
# Define o provedor Azure e a versao minima necessaria
# ---------------------------------------------------------------------------------------------------------------------
provider "azurerm" {
  features {}
  subscription_id = "a1b2c3d4-e5f6-7890-1234-567890abcdef"
  # version = "~> 3.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# VARIIAVEIS
# Declaracao de variaveis para facilitar a personalizacao e reuso do codigo
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_group_name" {
  description = "Nome do Grupo de Recursos onde os recursos serão criados."
  type        = string
  default     = "rg-demonstracao-terraform-001"
}

variable "location" {
  description = "Região do Azure onde os recursos serão implantados."
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Nome da Virtual Network."
  type        = string
  default     = "vnet-demonstracao-terraform-001"
}

variable "vnet_address_space" {
  description = "Espaço de endereço da Virtual Network (CIDR)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Nome da Subnet dentro da VNet."
  type        = string
  default     = "subnet-demonstracao-terraform-001"
}

variable "subnet_address_prefixes" {
  description = "Prefixos de endereço da Subnet (CIDR)."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "storage_account_name_prefix" {
  description = "Prefixo para o nome da Storage Account (será adicionado um sufixo aleatório)."
  type        = string
  default     = "stterraform"
}

variable "vm_count" {
  description = "Número de VMs a serem criadas."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Tamanho da VM (ex: Standard_B2s, Standard_DS1_v2)."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Nome de usuário administrador para as VMs."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Senha do administrador para as VMs (use algo seguro em produção!)."
  type        = string
  default     = "S3nh4Segur4!"
  sensitive   = true # Marca a variavel como sensivel para nao ser exibida em logs
}

# ---------------------------------------------------------------------------------------------------------------------
# RECURSOS DO AZURE
# Definicao dos recursos a serem criados no Azure
# ---------------------------------------------------------------------------------------------------------------------

# 1. Resource Group
# O Resource Group eh um container logico para os recursos do Azure
resource "azurerm_resource_group" "rg_demonstracao" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Demonstration"
    Project     = "Terraform"
  }
}

# 2. Virtual Network (VNet)
# A VNet eh a fundacao da sua rede privada no Azure
resource "azurerm_virtual_network" "vnet_demonstracao" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg_demonstracao.location
  resource_group_name = azurerm_resource_group.rg_demonstracao.name
  address_space       = var.vnet_address_space

  tags = {
    Network = "Main"
  }
}

# 3. Subnet
# A Subnet é uma segmentacao da sua VNet.
resource "azurerm_subnet" "subnet_demonstracao" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg_demonstracao.name
  virtual_network_name = azurerm_virtual_network.vnet_demonstracao.name
  address_prefixes     = var.subnet_address_prefixes
}

# 4. Storage Account
# A Storage Account eh usada para armazenar dados (blobs, files, queues, tables)
# Utiliza a funcao "random_id" para garantir um nome unico, pois nomes de Storage Account precisam ser globalmente unicos
resource "random_id" "storage_suffix" {
  byte_length = 8
}

resource "azurerm_storage_account" "st_demonstracao" {
  name                     = "${var.storage_account_name_prefix}${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg_demonstracao.name
  location                 = azurerm_resource_group.rg_demonstracao.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Local Redundant Storage

  tags = {
    DataStore = "GeneralPurpose"
  }
}

# 5. Network Interfaces (para VMs)
# Cada VM precisa de uma Network Interface para se conectar a rede
resource "azurerm_network_interface" "nic_demonstracao" {
  count               = var.vm_count # Cria N interfaces de rede
  name                = "nic-vm-demonstracao-${count.index}"
  location            = azurerm_resource_group.rg_demonstracao.location
  resource_group_name = azurerm_resource_group.rg_demonstracao.name

  ip_configuration {
    name                          = "internal-ip-config"
    subnet_id                     = azurerm_subnet.subnet_demonstracao.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Type = "VMNetwork"
  }
}

# 6. Virtual Machines (VMs)
# As VMs sao as maquinas virtuais propriamente ditas
resource "azurerm_linux_virtual_machine" "vm_demonstracao" {
  count               = var.vm_count # Cria N VMs
  name                = "vm-demonstracao-${count.index}"
  location            = azurerm_resource_group.rg_demonstracao.location
  resource_group_name = azurerm_resource_group.rg_demonstracao.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false # Mude para true e use chaves SSH em producao

  network_interface_ids = [
    azurerm_network_interface.nic_demonstracao[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    Workload = "DemonstrationVM"
    Instance = count.index
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SAIDAS (OUTPUTS)
# Define quais informacoes serao exibidas apos a aplicacao do Terraform
# ---------------------------------------------------------------------------------------------------------------------
output "resource_group_id" {
  description = "ID do Grupo de Recursos criado."
  value       = azurerm_resource_group.rg_demonstracao.id
}

output "vnet_id" {
  description = "ID da Virtual Network criada."
  value       = azurerm_virtual_network.vnet_demonstracao.id
}

output "subnet_id" {
  description = "ID da Subnet criada."
  value       = azurerm_subnet.subnet_demonstracao.id
}

output "storage_account_name" {
  description = "Nome da Storage Account criada."
  value       = azurerm_storage_account.st_demonstracao.name
}

output "vm_private_ips" {
  description = "Endereços IP privados das VMs criadas."
  value       = [for nic in azurerm_network_interface.nic_demonstracao : nic.private_ip_address]
}
