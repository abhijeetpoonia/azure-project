variable "region" {
  description = "Azure region"
}

variable "resource_group_name" {
  description = "Azure Resource Group name for AKS resources"
  type        = string
}

variable "client_id" {
  description = "The Client ID for the Azure Service Principal"
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the Azure Service Principal"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The Tenant ID for the Azure Service Principal"
  type        = string
}

variable "subscription_id" {
  description = "The Subscription ID for the Azure account"
  type        = string
}

variable "location" {
  description = "Azure Region where resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for the public subnet"
  type        = list(string)
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for the private subnet"
  type        = list(string)
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
}

variable "network_interface_name" {
  description = "Name of the network interface"
  type        = string
}

variable "common_tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster"
}

variable "cluster_name" {
  description = "AKS Cluster name"
}

variable "aks_node_name" {
  description = "AKS node name"
  default     = ""
}

variable "aks_nodegroup_name" {
  description = "AKS node group name"
}

variable "nodes_desired_count" {
  description = "Node count in the VMSS"
  default     = 2
}

variable "nodes_max_count" {
  description = "Autoscaling max count (not used in this example)"
  default     = 10
}

variable "nodes_min_count" {
  description = "Autoscaling min count (not used in this example)"
  default     = 1
}

variable "nodes_instance_types" {
  description = "Azure instance types to use"
  default     = "Standard_A2_v2"
}

variable "node_disk_size" {
  description = "Azure VM OS Disk size"
  default     = 100
}

variable "worker_vmss_name" {
  description = "VM Scale Set Name"
  default     = ""
}

variable "aks_cluster_version" {
  description = "AKS Kubernetes version"
  default     = "1.30"
}

variable "vm_name" {
  description = "Name of the Virtual Machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

variable "os_disk_size_gb" {
  description = "Disk size for the VM"
  type        = number
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "public_route_next_hop_ip" {
  description = "Next hop IP address for the public route"
  type        = string
}

variable "private_route_next_hop_ip" {
  description = "Next hop IP address for the private route"
  type        = string
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
}

variable "private_vm_name" {
  description = "Name of the Private Virtual Machine"
  type        = string
}

variable "private_vm_size" {
  description = "Size of the Private Virtual Machine"
  type        = string
}

variable "private_vm_admin_username" {
  description = "Admin username for the private VM"
  type        = string
}

variable "private_vm_admin_password" {
  description = "Admin password for the private VM"
  type        = string
  sensitive   = true
}

variable "private_vm_ssh_public_key_path" {
  description = "Path to the SSH public key for the private VM"
  type        = string
}

variable "private_vm_os_disk_size_gb" {
  description = "Disk size for the private VM"
  type        = number
}

variable "private_nic_name" {
  description = "Name of the Network Interface for the private VM"
  type        = string
}

variable "private_vm_nsg_name" {
  description = "Name of the Network Security Group for the private VM"
  type        = string
}

variable "bastion_ip" {
  description = "Source IP address or CIDR range allowed for SSH access to the private VM"
  type        = string
}

variable "bastion_subnet_name" {
  description = "Name of the Azure Bastion Subnet"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "CIDR block for the Azure Bastion Subnet"
  type        = list(string)
}

variable "bastion_public_ip_name" {
  description = "Name of the Public IP for Azure Bastion"
  type        = string
}

variable "bastion_public_ip_allocation_method" {
  description = "Allocation method for the Public IP (Static or Dynamic)"
  type        = string
}

variable "bastion_host_name" {
  description = "Name of the Azure Bastion Host"
  type        = string
}

variable "bastion_ip_configuration_name" {
  description = "Name of the IP Configuration for Azure Bastion"
  type        = string
}
