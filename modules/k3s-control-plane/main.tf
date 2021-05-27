resource "null_resource" "control_plane_first_node" {
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --write-kubeconfig-mode 644 --cluster-init --token ${var.k3s_token} --tls-san 1${var.lb_address}' INSTALL_K3S_VERSION='v1.19.1+k3s1' sh -"
    ]

    connection {
      type        = "ssh"
      host        = var.first_control_plane_node_ip
      user        = var.ssh_user
      private_key = var.private_key
      timeout      = "2m"
    }

    on_failure = continue
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.control_plane_first_node]

  create_duration = "60s"
}

resource "null_resource" "control_plane_subsequent_nodes" {
  count = length(var.subsequent_control_plane_node_ips)
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--write-kubeconfig-mode 644 --server https://${var.first_control_plane_node_ip}:6443 --token ${var.k3s_token}' INSTALL_K3S_VERSION='v1.19.1+k3s1' sh -"
    ]

    connection {
      type     = "ssh"
      host     = element(var.subsequent_control_plane_node_ips, count.index)
      user     = var.ssh_user
      private_key = var.private_key
      timeout      = "2m"
    }
    on_failure = continue
  }
  depends_on = [time_sleep.wait_60_seconds]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.control_plane_subsequent_nodes]

  create_duration = "30s"
}

resource "null_resource" "control_plane_first_node_config" {
  provisioner "remote-exec" {
    inline = [
      "sudo cp /etc/rancher/k3s/k3s.yaml ~/k3s.yaml",
      "sudo shutdown -r +10",
      "echo 0"
    ]

    connection {
      type        = "ssh"
      host        = var.first_control_plane_node_ip
      user        = var.ssh_user
      private_key = var.private_key
      timeout      = "2m"
    }

    on_failure = continue
  }

  depends_on = [time_sleep.wait_30_seconds]
}

resource "null_resource" "control_plane_subsequent_nodes_config" {
  count = length(var.subsequent_control_plane_node_ips)
  provisioner "remote-exec" {
    inline = [
      "sudo shutdown -r +10",
      "echo 0"
    ]

    connection {
      type     = "ssh"
      host     = element(var.subsequent_control_plane_node_ips, count.index)
      user     = var.ssh_user
      private_key = var.private_key
      timeout      = "2m"
    }
    on_failure = continue
  }
  depends_on = [time_sleep.wait_30_seconds]
}