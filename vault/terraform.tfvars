# General Configuration
resource_group_name       = "eshop-prod-rg"     
dns_prefix                = "eshop-prod"         
client_id                 = "2fb294f8-c0af-4566-85a6-d00b9b7c63ba"   
client_secret             = "EOz8Q~HOtdHR6BZga2nb-DR.RGJ-pQC2ncpyxcDZ"   
tenant_id                 = "df7cb3ac-555b-44cb-8898-e76543ad88fd"  
subscription_id           = "54a84062-8a4e-48e5-bad2-25c9222f33a1"  
region                    = "Central US"       

# AKS Configuration
cluster_name              = "eshop-prod-aks"    
aks_nodegroup_name        = "eshop-prod-aks-node-group"   
aks_node_name             = "eshop-prod-aks-node-group-node"   
nodes_min_count           = 2                     
nodes_max_count           = 3                     
nodes_desired_count       = 2                     
nodes_instance_types      = "Standard_A2_v2"      
node_disk_size            = 100                    
aks_cluster_version       = "1.30"                

# Network Configuration
vnet_name                 = "aks-vnet"            
vnet_address_space        = ["10.0.0.0/16"]        
public_subnet_name        = "aks-public-subnet"    
public_subnet_address_prefix  = ["10.0.1.0/24"]   
private_subnet_name       = "aks-private-subnet"   
private_subnet_address_prefix = ["10.0.2.0/24"]   

# Public VM Configuration
public_ip_name            = "public-ip"            
network_interface_name    = "public-nic"          
vm_name                   = "public-vm"          
vm_size                   = "Standard_DS2_v2"    
admin_username            = "azureuser"           
admin_password            = "Password123!"      
ssh_public_key_path       = "C:/Users/W/.ssh/id_rsa.pub"   
os_disk_size_gb           = 30                   
nsg_name                  = "aks-nsg"            
public_route_next_hop_ip  = "10.10.1.1"          

# Private VM Configuration
private_vm_name           = "private-vm"          
private_vm_size           = "Standard_DS2_v2"     
private_vm_admin_username = "azureuser"           
private_vm_admin_password = "Password123!"       
private_vm_ssh_public_key_path = "C:/Users/W/.ssh/id_rsa.pub"   
private_vm_os_disk_size_gb = 30                   
private_nic_name          = "private-nic"        
private_vm_nsg_name       = "private-vm-nsg"    
private_route_next_hop_ip  = "10.10.1.1"         

# Bastion Host Configuration
bastion_ip                = "52.176.47.220"     
bastion_subnet_name       = "AzureBastionSubnet"  
bastion_subnet_address_prefix = ["10.0.4.0/24"]   
bastion_public_ip_name    = "test-bastion-public-ip"   
bastion_public_ip_allocation_method = "Static"  
bastion_host_name         = "test-bastion"       
bastion_ip_configuration_name = "bastionIpConfiguration"   

# Tags and Environment Configuration
common_tags = {
  Project       = "eshop"                   
  Environment   = "prod"                     
  Managed       = "terraform"                  
  Component     = "k8s"                      
  SubComponent  = "shared"                    
  Vertical      = "operations"                 
  Resource      = "node-group"     
}

environment = "production"   
