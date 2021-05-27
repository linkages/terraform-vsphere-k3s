locals {
  public_key_filename = format(
    "%s/%s%s",
    var.ssh_public_key_path,
    var.ssh_key_name,
    var.public_key_extension
  )

  private_key_filename = format(
    "%s/%s%s",
    var.ssh_public_key_path,
    var.ssh_key_name,
    var.private_key_extension
  )
}

resource "tls_private_key" "default" {
  count     = var.generate_ssh_key == true ? 1 : 0
  algorithm = var.ssh_key_algorithm
}

resource "local_file" "public_key_openssh" {
  count      = var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default[0].public_key_openssh
  filename   = local.public_key_filename
}

resource "local_file" "private_key_pem" {
  count             = var.generate_ssh_key == true ? 1 : 0
  depends_on        = [tls_private_key.default]
  sensitive_content = tls_private_key.default[0].private_key_pem
  filename          = local.private_key_filename
  file_permission   = "0600"
}
