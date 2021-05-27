provider "vsphere" {
  user              = var.vsphere_user 
  password          = var.vsphere_password
  vsphere_server    = "vmconsole.hosting.it.ufl.edu"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

module "node" {
    source = "./k3s"

    # vsphere 
    availability_zone   = "AZ1"
    datastore_cluster   = "AZ1-Hosting-Gold"
    resource_pool       = "AZ1-DRS01/Resources"
    template            = "Ubuntu 20.04 Cloud Init"

    # Private TLS keys
    ssh_public_key_path     = "./secrets"
    ssh_key_name            = "k3s_user"
    generate_ssh_key        = true
    ssh_key_algorithm       = "RSA"
    private_key_extension   = ""
    public_key_extension    = ".pub"

    # keepalived

    lb_address      = "10.51.0.200"
    lb_priority     = 100
    interface       = "eth0"
    router_id       = 100

    # k3s nodes

    ssh_user        = "k3s-user"

    cp_instances    = 3
    cp_cpu          = 2
    cp_ram          = 2048
    cp_gateway      = "10.51.0.129"
    cp_subnetmask   = ["25"]
    cp_network      = {
        "2501-ict.az1.dft-mps.int-devops" = ["10.51.0.201","10.51.0.202","10.51.0.203"]
    }
    
    agent_instances     = 3
    agent_cpu           = 4
    agent_ram           = 4096
    agent_gateway       = "10.51.0.129"
    agent_subnetmask    = ["25"]
    agent_network       = {
        "2501-ict.az1.dft-mps.int-devops" = ["10.51.0.204","10.51.0.205","10.51.0.206"]
    }

    # Customer Info

    customer_name           = "ufit-dsc"
    customer_number         = "00001335"
    customer_tla            = "dsc"
    infrastructure_owner    = "IT-ICT-MICROSOFT-PL"
    service                 = "Utilities"
    ufit                    = "False"
    criticality             = "High"
    environment             = "prod"
    datacenter              = "Any"

    users                   = {
        "nicholas" = ["${var.ssh_key}"]
    }

}
