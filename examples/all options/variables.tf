variable "vsphere_user" {
  description = "vSphere user with rights to create VM's."
  type        = string
  default     = ""
}

variable "vsphere_password" {
  description = "Password for vSphere user"
  type        = string
  sensitive   = true
}

variable "ssh_key" {}