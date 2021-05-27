resource "null_resource" "k3s_kubeconfig" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_name} ${var.ssh_user}@${var.first_control_plane_node_ip}:/etc/rancher/k3s/k3s.yaml ./kube_config_cluster"
  }

}

resource "null_resource" "k3s_kubeconfig_rewrite" {
  provisioner "local-exec" {
    command = "sed -i 's/127.0.0.1/${var.lb_address}/g' ./kube_config_cluster"
  }
  depends_on = [null_resource.k3s_kubeconfig]
}
