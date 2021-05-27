local-hostname: ${hostname}
instance-id: ${instance_id}
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: no
      dhcp6: no
      addresses: [${ipv4}/${ipv4_subnetmask}]
      gateway4: ${ipv4_gateway}
      nameservers:
          search: [server.ufl.edu, infr.ufl.edu, ad.ufl.edu]
          addresses: [10.241.173.11, 10.253.173.11, 128.227.30.254, 8.6.245.30]