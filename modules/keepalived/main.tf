resource "random_password" "lb_password" {
  length           = 32
  special          = false
}

resource "random_integer" "router_id" {
  min = 51
  max = 255
}

data "template_file" "keepalive" {
  count = length(var.control_plane_node_ips)
  depends_on = [random_password.lb_password]
  template = "${file("${path.module}/templates/keepalived.conf.tpl")}"
  vars = {
    interface   = var.interface
    router_id   = random_integer.router_id.result
    lb_priority = "${var.lb_priority - count.index}"
    lb_password = random_password.lb_password.result
    lb_address  = var.lb_address
  }
}

resource "null_resource" "keepalive" {

  count = length(var.control_plane_node_ips)

  provisioner "remote-exec" {
    inline = var.distro == "ubuntu" ? [
      "apt-get update -y",
      "sudo apt-get install linux-headers-$(uname -r) -y",
      "sudo apt-get install keepalived -y"
    ] : [ 
      "sudo pacman -Sy --noconfirm keepalived"
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.keepalive[count.index].rendered}"
    destination = "~/keepalived.conf"
  }

  provisioner "remote-exec" {
    inline = var.distro == "ubuntu" ? [
      "sudo mv ~/keepalived.conf /etc/keepalived/keepalived.conf",
      "sudo service keepalived start"
    ] : [
      "sudo mv ~/keepalived.conf /etc/keepalived/keepalived.conf",
      "sudo systemctl start keepalived",
      "sudo systemctl enable keepalived"
    ]
  }

  connection {
    type        = "ssh"
    host        = element(var.control_plane_node_ips, count.index)
    user        = var.ssh_user
    private_key = var.private_key
    timeout      = "2m"
  }

  depends_on = [data.template_file.keepalive]

}
