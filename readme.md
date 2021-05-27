# Terraform-vSphere-k3s

This module will create a k3s HA deployment in a single AZ.  It uses the embedded [etcd](https://etcd.io/) for shared configuration across the control plane nodes, because of this it is requires that you follow the appropriate quorum guideline's for control plan nodes.

**Upcoming Features**
- Request Ip's from infoblox
- Set DNS in infoblox
- deploy [metallb](https://metallb.universe.tf/) with the cluster
- deploy [prometheus](https://prometheus.io/) with the cluster

# Table of Contents

- [Terraform-vSphere-k3s](#terraform-vsphere-k3s)
- [Table of Contents](#table-of-contents)
  - [How to use](#how-to-use)
    - [Options](#options)
      - [Required](#required)
      - [Optional](#optional)
    - [Outputs](#outputs)

## How to use

**Simple Example**

<details><summary>Click here to expand...</summary><p>

``` hcl
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

    lb_address      = "10.51.0.201"

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
```

</p></details>

**Full Example**

<details><summary>Click here to expand...</summary><p>

``` hcl
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

    lb_address      = "10.51.0.201"
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
```

</p></details>


### Options

Below are all of the options available for you to configure when using this module.  They are broken into the catagories of *Required* and *Optional*.  Options that are **not** expecting strings will list the `type` of information that are expecting. 

#### Required

**`availability_zone`**
- Availability Zone where to deploy the k3s cluster.
- Must have a value of **AZ1**, **AZ2**, or **AZ3**

**`lb_address`**
- Load Balanced/HA address for k3s Control Plane.

**`cp_instances`**
- Number of Control Plane nodes to create.
- Must have a value of **1**, **3**, or **5** 

**`cp_network`**
- Network and IPs to assign to the Control Plane nodes.
- *Type*: Map(list(string))

**`cp_gateway`**
- Gateway for the network used by the Control Plane nodes.

**`agent_instances`**
- Number of Agents to create.

**`agent_network`**
- Network and IPs to assign to the Agent nodes.
- *Type*: Map(list(string))

**`agent_gateway`**
- Gateway for the network used by the Control Plane nodes.

**`customer_name`**
- The business group name that the Cluster belongs to.

**`customer_number`**
- Customer number associated with the Business Group/Customer Name.

**`customer_tla`**
- Three letter acronym associated with the cluster or Group/Customer Name.

**`infrastructure_owner`**
- The UFIT unit that the Cluster belongs to.

**`service`**
- The service the Cluster supports.

**`users`**
- User and Public SSH keys to add to to all nodes.
- *Type*: Map(list(string))

#### Optional

**`datastore_cluster`**
- Datastore Cluster in hosting.ufl.edu to deploy the k3s cluster to.
- *Default*: ${var.availability_zone}-Hosting-Gold

**`resource_pool`**
- Resource Pool in hosting.ufl.edu to deploy the k3s cluster to.
- *Default*: ${var.availability_zone}-DRS01/Resources

**`template`**
- Template to use when creating nodes for the k3s cluster.
- *Default*: Ubuntu 20.04 Cloud Init

**`cp_cpu`**
- Number of CPU's to attach to control plane nodes
- *Type*: number
- *Default*: 2

**`cp_ram`**
- Ammount of Ram to attach to control plane nodes
- *Type*: number
- *Default*: 2048

**`cp_subnetmask`**
- "subnetmask for subnet/vlan Control Plane nodes are on (eg. 24, 25, 26)."
- *Type*: list(string)
- *Default*: ["24"]

**`agent_cpu`**
- Number of CPU's to attach to control plane nodes
- *Type*: number
- *Default*: 2

**`agent_ram`**
- Ammount of Ram to attach to control plane nodes
- *Type*: number
- *Default*: 2048

**`agent_subnetmask`**
- subnetmask for subnet/vlan Control Plane nodes are on (eg. 24, 25, 26).
- *Type*: list(string)
- *Default*: ["24"]

**`ufit`**
- Does this system belong to a UFIT unit.
- *Default*: "True"

**`criticality`**
- Importance of the Cluster to Operations (e.g Low, Medium, High).
- *Default*: Low

**`environment`**
- environment (eg. lab, dev, test, qat, prod) for the cluster.
- *Default*: prod

**`datacenter`**
- Datacenter affinity for Control Plane nodes.
- *Default*: Any

**`ssh_user`**
- User account to use for initial install and configuration of k3s cluster
- *Default*: k3s-user

**`ssh_public_key_path`**
- Path to SSH public key directory (e.g. `/secrets`)
- *Default*: "./secrets"

**`ssh_key_name`**
- Name to use when generating SSH keys
- *Default*: k3s_user

**`generate_ssh_key`**
- If set to `true`, new SSH key pair will be created and `ssh_public_key_file` will be ignored
- *Default*: true

**`ssh_key_algorithm`**
- SSH key algorithm to use when generating Dynamic SSH keys
- *Default*: RSA

**`private_key_extension`**
- Private key extension to use
- *Default*: ""

**`public_key_extension`**
- Public key extension to use
- *Default*: ".pub"

**`lb_priority`**
- Starting priority for Keepalived
- *Default*: 100

**`interface`**
- Name of network interface
- *Default*: ens192

**`router_id`**
- Router ID for Keepalived
- *Default*: 100

### Outputs


