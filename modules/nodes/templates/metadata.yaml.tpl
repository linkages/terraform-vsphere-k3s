local-hostname: ${hostname}
instance-id: ${instance_id}
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses: [${ipv4}/${ipv4_subnetmask}]
      gateway4: ${ipv4_gateway}
      nameservers:
          search: [ ${dns_domain} ]
          addresses: [%{ for i in dns_servers ~} ${i} %{ endfor ~}]