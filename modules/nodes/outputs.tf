output "Node-VM" {
  description = "VM Names"
  value       = vsphere_virtual_machine.node.*.name
}

output "Node-ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.node.*.default_ip_address
}


