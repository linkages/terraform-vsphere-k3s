variable "lb_address" {
    description = "Load Balanced address for k3s Control Plane"
    type        = string
}

variable "control_plane_node_ips" {
    description = "IP addresses of the control plane nodes"
    type        = list
}

variable "ssh_user" {
    description = "User with ssh access to Nodes"
    type        = string
}

variable "private_key" {
    description = "Path to ssh private key"
    type        = string
}

variable "lb_priority" {
    description = "Starting priority for loadbalncers"
    type = number
}

variable "interface" {
    description = "Name of network interface"
    type = string
}

variable "distro" {
  description = "linux distribution"
  type = string
}