// provider "vsphere" {
//   user              = var.vsphere_user 
//   password          = var.vsphere_password
//   vsphere_server    = "vmconsole.hosting.it.ufl.edu"

//   # if you have a self-signed cert
//   allow_unverified_ssl = true
// }

data "vsphere_datacenter" "availability_zone" {
  name = var.availability_zone
}

data "vsphere_network" "network" {
  count         = length(var.network)
  name          = keys(var.network)[count.index]
  datacenter_id = data.vsphere_datacenter.availability_zone.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.availability_zone.id
}

locals {
  interface_count     = length(var.subnetmask) #Used for Subnet handeling
  template_disk_count = length(data.vsphere_virtual_machine.template.disks)
  vm_folder           = "UF Hosting/${var.customer_name}"
  resource_pool       = "${var.availability_zone}-DRS01/Resources"
  datastore_cluster   = "${var.availability_zone}-Hosting-Gold"
  tags = {
    "Customer Name"        = var.customer_name
    "Infrastructure Owner" = var.infrastructure_owner
    "UFIT"                 = var.ufit
    "Customer Number"      = var.customer_number
    "Criticality"          = var.criticality
    "Service"              = var.service
    "Environment Tier"     = var.environment
    "Availability Zone"    = var.availability_zone
    "Data Center"          = var.datacenter
  }

}

data "vsphere_datastore_cluster" "datastore_cluster" {
  count         = 1
  name          = "%{if var.datastore_cluster != ""}${var.datastore_cluster}%{else}${local.datastore_cluster}%{endif}"
  datacenter_id = data.vsphere_datacenter.availability_zone.id
}

data "vsphere_resource_pool" "pool" {
  name          = "%{if var.resource_pool != ""}${var.resource_pool}%{else}${local.resource_pool}%{endif}"
  datacenter_id = data.vsphere_datacenter.availability_zone.id
}

data "vsphere_tag_category" "category" {
  count = local.tags != null ? length(local.tags) : 0
  name  = keys(local.tags)[count.index]
}

data "vsphere_tag" "tag" {
  count       = local.tags != null ? length(local.tags) : 0
  name        = local.tags[keys(local.tags)[count.index]]
  category_id = data.vsphere_tag_category.category[count.index].id
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
  name                    = "${var.availability_zone}-k3s-${var.customer_tla}-${var.role_name}-${random_id.node.*.hex[count.index]}"
  folder                  = local.vm_folder
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
    "guestinfo.metadata"  = base64encode(templatefile("${path.module}/templates/metadata.yaml.tpl", {
      hostname            = "${var.availability_zone}-k3s-${var.customer_tla}-${var.role_name}-${random_id.node.*.hex[count.index]}.server.ufl.edu"
      instance_id         = "${var.availability_zone}-k3s-${var.customer_tla}-${var.role_name}-${random_id.node.*.hex[count.index]}"
      ipv4                = var.network[keys(var.network)[0]][count.index]
      ipv4_subnetmask     = var.subnetmask[0]
      ipv4_gateway        = var.gateway
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(templatefile("${path.module}/templates/userdata.yaml.tpl", {
      k3s_pub_key = var.k3s_pub_key
      users = var.users
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
  
  lifecycle { ignore_changes = [clone.0.template_uuid] }
}

