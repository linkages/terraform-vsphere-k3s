# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------



# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Nodes
# ---------------------------------------------------------------------------------------------------------------------

# vsphere
variable "datacenter" {
  description = "datacenter (eg. SSRB, UFDC, Any)"
  type        = string
  default     = "Any"
}

variable "dns_domain" {
  description = "DNS domain to use for all deployed nodes"
  type = string
}

variable "dns_servers" {
  description = "List of DNS servers to query"
  type = list
}

variable "metadata_file" {
  description = "Metadata file passed to the VM"
  type = string
}

variable "userdata_file" {
  description = "Userdata file passed to the VM"
  type = string
}

variable "cluster_name" {
  description = "Unique name for this k3s cluster"
  type = string
}

variable "vm_folder" {
  description = "vSphere folder where VM will be deployed"
  type = string
}

# Node Info

variable "cp_instances" {
  description = "Number of Control Plane Nodes to Create (eg. 1, 3, 5)"
  type       = number
  default    = 1

  validation {
    condition     = contains([1,3, 5], var.cp_instances)
    error_message = "Must be a vault of 1, 3, or 5."
  }
}

variable "cp_gateway" {
  description = "Gateway for subnet/vlan"
  type        = string
  default     = ""
}

variable "cp_network" {
  description = "Network and IPs to assign to the Control Plane nodes."
  type        = map(list(string))
  default     = {}
}

variable "agent_instances" {
  description = "Number of Agents to create."
  type       = number
  default    = 1

}

variable "agent_gateway" {
  description = "Gateway for subnet/vlan"
  type        = string
  default     = ""
}

variable "agent_network" {
  description = "Network and IPs to assign to the Agent nodes."
  type        = map(list(string))
  default     = {}
}

# customer Info

variable "users" {
  description = "users to add to the sudo group"
  type        = map(list(string))
  default     = {}
}

variable "lb_address" {
    description = "Load Balanced/HA address for k3s Control Plane"
    type        = string
    default = ""
}

variable "worker_role_name" {
  description = "Naming convention of worker nodes, this is used when generating hostnames"
  type        = string
  default     = "worker"
}

variable "cp_role_name" {
  description = "Naming convention of control plane nodes, this is used when generating hostnames"
  type        = string
  default     = "ctrl"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "distro" {
  description = "Linux distro used by the VMs"
  type = string
}

variable "datastore" {
  type = string
  description = "Datastore to deploy the k3s cluster to."
  default = ""
}

variable "resource_pool" {
  type = string
  default = ""
}

variable "template" {
  description = "template in vsphere to use when creating VM's"
  type       = string
}

variable "cp_cpu" {
  description = "Number of CPU's to attach to control plane nodes"
  type        = number
  default     = 2
}

variable "cp_ram" {
  description = "Ammount of Ram to attach to control plane nodes"
  type        = number
  default     = 2048
}

variable "cp_subnetmask" {
  description = "subnetmask for subnet/vlan vm is ceated on (eg. 24, 25, 26)"
  type        = list(string)
  default     = ["24"]
}

variable "agent_cpu" {
  description = "Number of CPU's to attach to control plane nodes"
  type        = number
  default     = 2
}

variable "agent_ram" {
  description = "Ammount of Ram to attach to control plane nodes"
  type        = number
  default     = 2048
}

variable "agent_subnetmask" {
  description = "subnetmask for subnet/vlan cluster is ceated on (eg. 24, 25, 26)"
  type        = list(string)
  default     = ["24"]
}

# Customer Info

variable "ufit" {
  description = "Does this cluster belong to a UFIT unit true/false"
  type        = string
  default     = "True"

  validation {
    condition     = contains(["True", "False"], var.ufit)
    error_message = "The ufit variable must be one of: true or false."
  }
}

variable "criticality" {
  description = "Importance of the Cluster to Operations (e.g Low, Medium, High)"
  type        = string
  default     = "Low"

  validation {
    condition     = contains(["Critical", "High", "Medium", "Low"], var.criticality)
    error_message = "The criticality variable must be one of: Critical, High, Medium, or Low."
  }
}

variable "environment" {
  description = "environment (eg. lab, dev, test, qat, prod) to be used when calculating the vm name"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["lab", "dev", "test", "qat","prod"], var.environment)
    error_message = "The environment variable must be one of: lab, dev, test, qat, or prod."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# K3s
# ---------------------------------------------------------------------------------------------------------------------

# all

variable "ssh_user" {
    description = "User account to use for intail install and configuration of k3s"
    type        = string
    default     = "k3s-user"
}

# ---------------------------------------------------------------------------------------------------------------------
# Private TLS
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
  default     = "./secrets"
}

variable "ssh_key_name" {
  type        = string
  description = "name to use when generating SSH keys"
  default     = "k3s_user"
}

variable "generate_ssh_key" {
  type        = bool
  default     = true
  description = "If set to `true`, new SSH key pair will be created and `ssh_public_key_file` will be ignored"
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm"
}

variable "private_key_extension" {
  type        = string
  default     = ""
  description = "Private key extension to use"
}

variable "public_key_extension" {
  type        = string
  default     = ".pub"
  description = "Public key extension to use"
}

variable "lb_priority" {
    description = "Starting priority for Keepalived"
    type = number
    default = 100
}

variable "interface" {
    description = "Name of network interface"
    type = string
    default = "eth0"
}
