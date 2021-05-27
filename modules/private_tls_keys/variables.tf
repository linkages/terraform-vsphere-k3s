variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of existing for key pair"
}

variable "generate_ssh_key" {
  type        = bool
  description = "If set to `true`, new SSH key pair will be created and `ssh_public_key_file` will be ignored"
}

variable "ssh_key_algorithm" {
  type        = string
  description = "SSH key algorithm"
}

variable "private_key_extension" {
  type        = string
  description = "Private key extension"
}

variable "public_key_extension" {
  type        = string
  description = "Public key extension"
}
