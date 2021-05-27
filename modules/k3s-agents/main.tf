resource "null_resource" "agent_nodes" {

  count = length(var.agent_node_ips)
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${var.first_control_plane_node_ip}:6443 K3S_TOKEN=${var.k3s_token} INSTALL_K3S_VERSION='v1.19.1+k3s1' sh -"
    ]

    connection {
      type        = "ssh"
      host        = element(var.agent_node_ips, count.index)
      user        = var.ssh_user
      private_key = var.private_key
      timeout      = "2m"
    }
  }

}