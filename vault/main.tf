terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  skip_provider_registration = true
  
  
  client_id                  = var.client_id
  client_secret              = var.client_secret
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
}

locals {
  aks_node_name_tag = "aks-node"
  worker_vmss_name  = "aks-vmss"   
}

# Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  tags = var.common_tags
}

# Create public subnet
resource "azurerm_subnet" "aks_public_subnet" {
  name                 = var.public_subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.public_subnet_address_prefix

  depends_on = [azurerm_virtual_network.aks_vnet]
}

# Create private subnet
resource "azurerm_subnet" "aks_private_subnet" {
  name                 = var.private_subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.private_subnet_address_prefix

  depends_on = [azurerm_virtual_network.aks_vnet]
}

# Create public IP
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  allocation_method = "Static"
}

# Create Network Interface
resource "azurerm_network_interface" "public_nic" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aks_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  depends_on = [
    azurerm_public_ip.public_ip,
    azurerm_subnet.aks_public_subnet
  ]
}

# Create Public Virtual Machine
resource "azurerm_linux_virtual_machine" "public_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.public_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = var.os_disk_size_gb
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

# Network Security Group
resource "azurerm_network_security_group" "aks_nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "public_nic_nsg" {
  network_interface_id      = azurerm_network_interface.public_nic.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# Create Public Route Table
resource "azurerm_route_table" "public_route_table" {
  name                = "public-route-table"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name                   = "public-route"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.public_route_next_hop_ip
  }
}

resource "azurerm_subnet_route_table_association" "public_association" {
  subnet_id      = azurerm_subnet.aks_public_subnet.id
  route_table_id = azurerm_route_table.public_route_table.id
}

# Create Private Route Table
resource "azurerm_route_table" "private_route_table" {
  name                = "private-route-table"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name                   = "private-route"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.private_route_next_hop_ip
  }
}

resource "azurerm_subnet_route_table_association" "private_association" {
  subnet_id      = azurerm_subnet.aks_private_subnet.id
  route_table_id = azurerm_route_table.private_route_table.id
}
# Create Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location   
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.aks_cluster_version

  default_node_pool {
    name            = "default"
    vm_size         = var.nodes_instance_types
    node_count      = var.nodes_desired_count
    max_pods        = 110
    os_disk_size_gb = var.node_disk_size

    vnet_subnet_id = azurerm_subnet.aks_public_subnet.id   
    tags = merge(var.common_tags, {
      Name     = var.aks_nodegroup_name
      Resource = "node-group"
    })
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    dns_service_ip     = "10.0.3.4"
    service_cidr       = "10.0.3.0/24"
  }

  tags = var.common_tags
}

# Commented out VM Scale Set
# resource "azurerm_virtual_machine_scale_set" "aks_vmss" {
#   name                = local.worker_vmss_name
#   location            = azurerm_resource_group.aks_rg.location
#   resource_group_name = azurerm_resource_group.aks_rg.name
#   upgrade_policy_mode = "Manual"
#
#   sku {
#     name     = "Standard_DS2_v2"
#     capacity = 3
#   }
#
#   os_profile {
#     computer_name_prefix = "vmss"
#     admin_username       = "azureuser"
#     admin_password       = "Password123!"  # Use a more secure password in production
#   }
#
#   storage_profile_os_disk {
#     caching              = "ReadWrite"
#     managed_disk_type    = "Standard_LRS"
#   }
#
#   network_profile {
#     name    = "aks-vmss-nic"
#     primary = true
#     ip_configuration {
#       name      = "aks-vmss-ip-config"
#       subnet_id = azurerm_subnet.aks_public_subnet.id
#     }
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   tags = {
#     environment = "production"
#   }
# }
##################################################################################################################
# Create Private Virtual Machine
resource "azurerm_linux_virtual_machine" "private_vm" {
  name                = var.private_vm_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  size                = var.private_vm_size
  admin_username      = var.private_vm_admin_username
  admin_password      = var.private_vm_admin_password
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.private_nic.id,
  ]

  admin_ssh_key {
    username   = var.private_vm_admin_username
    public_key = file(var.private_vm_ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = var.private_vm_os_disk_size_gb
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

# Create Network Interface for Private VM
resource "azurerm_network_interface" "private_nic" {
  name                = var.private_nic_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.aks_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.aks_private_subnet
  ]
}

# Network Security Group for Private VM
resource "azurerm_network_security_group" "private_vm_nsg" {
  name                = var.private_vm_nsg_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "AllowSSHFromBastion"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.bastion_ip   
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}
############################# this is for mysql azure private-endpoint ##########################################
#   # Allow MySQL traffic from the private VM to the MySQL server via the Private Endpoint
#   security_rule {
#     name                       = "AllowMySQLFromPrivateVM"
#     priority                   = 1002
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "3306" # MySQL port
#     source_address_prefix      = "*"
#     destination_address_prefix = local.mysql_server_fqdn # MySQL server FQDN
#   }

#   tags = {
#     environment = "production"
#   }
# }



####################################baston#########################################################
# Create a dedicated subnet for Azure Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.bastion_subnet_address_prefix
}

# Create a Public IP for Azure Bastion
resource "azurerm_public_ip" "test_bastion_public_ip" {
  name                = var.bastion_public_ip_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  allocation_method = var.bastion_public_ip_allocation_method
  
  sku = "Standard"
}

# Create Azure Bastion Host
resource "azurerm_bastion_host" "test_bastion" {
  name                = var.bastion_host_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                 = var.bastion_ip_configuration_name
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.test_bastion_public_ip.id
  }

  tags = {
    environment = var.environment
  }
}

################################for azure privte endpoint###########################
# locals {
#   mysql_server_name            = "your-mysql-server-name" # Update with your MySQL server name
#   mysql_server_resource_group  = "your-mysql-server-resource-group" # Update if MySQL is in a different resource group
#   mysql_server_location        = "Central US" # Update based on your MySQL server location
#   mysql_server_fqdn           = "${local.mysql_server_name}.mysql.database.azure.com" # FQDN format for Azure MySQL
#   mysql_server_resource_id     = "/subscriptions/${var.subscription_id}/resourceGroups/${local.mysql_server_resource_group}/providers/Microsoft.DBforMariaDB/servers/${local.mysql_server_name}" # Update with your MySQL server resource ID
# }

# # Create a Private Endpoint for MySQL
# resource "azurerm_private_endpoint" "mysql_private_endpoint" {
#   name                = "mysql-private-endpoint"
#   resource_group_name = azurerm_resource_group.aks_rg.name  # Use existing resource group
#   location            = local.mysql_server_location          # MySQL server location
#   subnet_id          = azurerm_subnet.aks_private_subnet.id  # Subnet for the Private Endpoint

#   private_service_connection {
#     name                           = "mysql-connection"
#     private_connection_resource_id = local.mysql_server_resource_id  # MySQL server resource ID
#     is_manual_connection           = false

#     private_link_service_connection {
#       name                     = "mysql-private-link"
#       private_link_service_id = local.mysql_server_resource_id  # MySQL server resource ID
#       group_ids               = ["mysqlServer"]
#       request_message          = "Please approve this connection"
#     }
#   }
# }
# # Ensure the Private VM has NSG rules to allow outbound traffic to the Private Endpoint
# resource "azurerm_network_interface_security_group_association" "private_nic_nsg" {
#   network_interface_id      = azurerm_network_interface.private_nic.id
#   network_security_group_id = azurerm_network_security_group.private_vm_nsg.id
# }
