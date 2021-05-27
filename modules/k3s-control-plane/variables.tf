variable "lb_address" {
    description = "Load Balanced address for k3s Control Plane"
    type        = string
}

variable "first_control_plane_node_ip" {
    description = "IP address of the first control plane node"
    type        = string
}

variable "subsequent_control_plane_node_ips" {
    description = "IP's of remaining Control Plane nodes"
    type        = list(string)

}

variable "ssh_user" {
    description = "User with ssh access to Nodes"
    type        = string
}

variable "private_key" {
    description = "Path to ssh private key"
    type        = string
}

variable "k3s_token" {
    description = "Token used to join k3s custer"
    type        = string
}