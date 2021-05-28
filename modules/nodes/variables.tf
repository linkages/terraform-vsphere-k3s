# ---------------------------------------------------------------------------------------------------------------------
# UF vSphere Info
# ---------------------------------------------------------------------------------------------------------------------

variable "datastore" {
  description = "Datastore to deploy this VM into"
  type = string
}

variable "resource_pool" {
  description = "Name of the resource pool where this VM will be deployed."
  type = string
}

variable "vm_folder" {
  description = "vSphere folder where VM will be deployed"
  type = string
}

variable "template" {
  description = "template in vsphere to use when creating VM's"
  type       = string
}

variable "gateway" {
  description = "Gateway for subnet/vlan"
  type        = string
}

variable "subnetmask" {
  description = "subnetmask for subnet/vlan vm is ceated on (eg. 24, 25, 26)"
  type        = list(string)
}

variable "network" {
  description = "Network (eg. vsphere port group) and IP to assign to the VM."
  type        = map(list(string))
}

variable "instances" {
  description = "Number of Control Plane Nodes to Create (eg. 1, 3, 5)"
  type       = number
}

variable "cpu" {
  description = "Number of CPU's to attach to control plane nodes"
  type        = number
}

variable "ram" {
  description = "Ammount of Ram to attach to control plane nodes"
  type        = number
}

variable "role_name" {
  description = "Role name for node typically worker or ctrl"
  type        = string
  validation {
    condition     = contains(["worker", "ctrl"], var.role_name)
    error_message = "The role_name variable must be one of: worker or ctrl."
  }
}

variable "dns_domain" {
  description = "DNS domain"
  type = string
}

variable "cluster_name" {
  description = "unique name for this cluster"
  type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# UF Customer Info
# ---------------------------------------------------------------------------------------------------------------------

variable "datacenter" {
  description = "datacenter (eg. SSRB, UFDC, Any)"
  type        = string
}

variable "users" {
  description = "users to add to the sudo group"
  type        = map(list(string))
}

variable "k3s_pub_key" {
  description = "tls pub key for k3s user"
  type        = string
}