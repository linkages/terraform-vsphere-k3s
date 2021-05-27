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

    # k3s nodes

    lb_address      = "10.51.0.200"

    cp_instances    = 3
    cp_gateway      = "10.51.0.129"
    cp_subnetmask   = ["25"]
    cp_network      = {
        "2501-ict.az1.dft-mps.int-devops" = ["10.51.0.201","10.51.0.202","10.51.0.203"]
    }

    agent_instances     = 2
    agent_gateway       = "10.51.0.129"
    agent_subnetmask    = ["25"]
    agent_network       = {
        "2501-ict.az1.dft-mps.int-devops" = ["10.51.0.204","10.51.0.205"]
    }

    # Customer Info

    customer_name           = "ufit-dsc"
    customer_number         = "00001335"
    customer_tla            = "dsc"
    infrastructure_owner    = "IT-ICT-MICROSOFT-PL"
    service                 = "Utilities"
    users                   = {
        "nicholas" = ["${var.ssh_key}"]
    }

}
