// provider "vsphere" {
//   user              = var.vsphere_user 
//   password          = var.vsphere_password
//   vsphere_server    = "vmconsole.hosting.it.ufl.edu"

//   # if you have a self-signed cert
//   allow_unverified_ssl = true
// }

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_network" "network" {
  count         = length(var.network)
  name          = keys(var.network)[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

locals {
  interface_count     = length(var.subnetmask) #Used for Subnet handeling
  template_disk_count = length(data.vsphere_virtual_machine.template.disks)
  resource_pool       = "${var.datacenter}-DRS01/Resources"
}

data "vsphere_datastore" "datastore" {
  count         = 1
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "%{if var.resource_pool != ""}${var.resource_pool}%{else}${local.resource_pool}%{endif}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "random_id" "node" {
  count         = var.instances
  keepers       = {
    template_id = data.vsphere_virtual_machine.template.id
  }
  byte_length   = 2
}

resource "vsphere_virtual_machine" "node" {
  count                   = var.instances
  name                    = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}"
  folder                  = var.vm_folder
  resource_pool_id        = data.vsphere_resource_pool.pool.id

  num_cpus                = var.cpu
  num_cores_per_socket    = 1
  cpu_hot_add_enabled     = true
  cpu_hot_remove_enabled  = true
  memory                  = var.ram
  memory_hot_add_enabled  = true
  guest_id                = data.vsphere_virtual_machine.template.guest_id

  dynamic "network_interface" {
    for_each        = keys(var.network) #data.vsphere_network.network[*].id #other option
    content {
      network_id    = data.vsphere_network.network[network_interface.key].id
      adapter_type  = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
  }

  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks
    content {
      label             = "disk${template_disks.key}"
      size              = data.vsphere_virtual_machine.template.disks[template_disks.key].size
      thin_provisioned  = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub     = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"  = var.metadata_file == "" ? base64encode(templatefile("${path.module}/templates/metadata.yaml.tpl", {
      hostname            = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}.${var.dns_domain}"
      instance_id         = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}"
      ipv4                = var.network[keys(var.network)[0]][count.index]
      ipv4_subnetmask     = var.subnetmask[0]
      ipv4_gateway        = var.gateway
      dns_domain          = var.dns_domain
      dns_servers         = var.dns_servers
    })) : base64encode(templatefile("${var.metadata_file}", {
      hostname            = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}.${var.dns_domain}"
      instance_id         = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}"
      ipv4                = var.network[keys(var.network)[0]][count.index]
      ipv4_subnetmask     = var.subnetmask[0]
      ipv4_gateway        = var.gateway
      dns_domain          = var.dns_domain
      dns_servers         = var.dns_servers
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = var.userdata_file == "" ? base64encode(templatefile("${path.module}/templates/userdata.yaml.tpl", {
      k3s_pub_key = var.k3s_pub_key
      users = var.users
      hostname = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}.${var.dns_domain}"
    })) : base64encode(templatefile("${var.userdata_file}", {
      k3s_pub_key = var.k3s_pub_key
      users = var.users
      hostname = "k3s-${var.cluster_name}-${var.role_name}-${random_id.node.*.hex[count.index]}.${var.dns_domain}"
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
  
  lifecycle { ignore_changes = [clone.0.template_uuid] }
}
