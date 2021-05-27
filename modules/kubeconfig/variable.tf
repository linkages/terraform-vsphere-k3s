variable "first_control_plane_node_ip" {
    description = "IP address of the first control plane node"
    type        = string
}

variable "private_key_name" {
    description = "Path to ssh private key"
    type        = string
}

variable "ssh_user" {
    description = "User with ssh access to Nodes"
    type        = string
}

variable "lb_address" {
    description = "Load Balanced address for k3s Control Plane"
    type        = string
    default = ""
}