# ---------------------------------------------------------------------------------------------------------------------
# UF vSphere Info
# ---------------------------------------------------------------------------------------------------------------------

variable "datastore_cluster" {
  type = string
}

variable "resource_pool" {
  type = string
}

variable "availability_zone" {
  description = "Availability Zone (eg. AZ1, AZ2, AZ3) to deploy the VM into"
  type        = string

  validation {
    condition     = contains(["AZ1", "AZ2", "AZ3"], var.availability_zone)
    error_message = "The availability_zone variable must be one of: AZ1, AZ2, or AZ3."
  }
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

# ---------------------------------------------------------------------------------------------------------------------
# UF Customer Info
# ---------------------------------------------------------------------------------------------------------------------

variable "customer_name" {
  description = "The business group name that the VM belongs to"
  type        = string
}

variable "customer_number" {
  description = "Customer number associated with the Business Group/Customer Name"
  type        = string
}
variable "customer_tla" {
  description = "Customer three letter acronym Group/Customer Name"
  type        = string
}

variable "infrastructure_owner" {
  description = "the UFIT unit that the VM belongs to"
  type        = string
}

variable "service" {
  description = "The service the VM supports"
  type        = string
}

variable "ufit" {
  description = "Does this VM belong to a UFIT unit true/false"
  type        = string
}

variable "criticality" {
  description = "Importance of the VM to Operations (e.g Low, Medium, High)"
  type        = string
}

variable "environment" {
  description = "environment (eg. lab, dev, test, qat, prod) to be used when calculating the vm name"
  type        = string
}

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