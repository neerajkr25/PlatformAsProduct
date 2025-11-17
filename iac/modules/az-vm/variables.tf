variable "resource_group_name" {
  type        = string
  description = "Resource Group where the VM will be created"
}

variable "location" {
  type    = string
  default = "UAE North"
}

variable "vnet_subnet_id" {
  type        = string
  description = "ID of the existing subnet where the VM will be placed (must be same VNet as AKS)"
}

variable "vm_name" {
  type    = string
  default = "jump-vm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

# IMPORTANT: supply the public key contents from the root module (do NOT call file() inside module)
variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key string (ssh-rsa ...). Read with file() at root and pass into module."
}

variable "create_public_ip" {
  type    = bool
  default = false
  description = "Set true only for temporary access (not recommended). If false, use Bastion."
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
  description = "CIDR allowed to access the public IP (used only when create_public_ip = true)."
}

variable "os_image_publisher" {
  type    = string
  default = "Canonical"
}

variable "os_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-focal"
}

variable "os_image_sku" {
  type    = string
  default = "20_04-lts-gen2"
}

variable "os_image_version" {
  type    = string
  default = "latest"
}

# If you want VM to be able to fetch kubeconfig without manual az login, pass AKS resource id:
# e.g. "/subscriptions/.../resourceGroups/.../providers/Microsoft.ContainerService/managedClusters/<cluster-name>"
variable "aks_resource_id" {
  type        = string
  default     = ""
  description = "Optional: AKS resource id to grant VM managed identity 'Azure Kubernetes Service Cluster Admin Role'"
}

# Cloud-init extra commands (optional)
variable "extra_cloudinit_commands" {
  type    = list(string)
  default = []
  description = "Additional commands appended to cloud-init runcmd (each element is a shell command string)."
}
