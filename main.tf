resource "random_string" "k3s_token" {
  length           = 32
  special          = false
}

module "private_tls" {
    source                  = "./modules/private_tls_keys"
    
    ssh_public_key_path     = var.ssh_public_key_path
    ssh_key_name            = var.ssh_key_name
    generate_ssh_key        = var.generate_ssh_key
    ssh_key_algorithm       = var.ssh_key_algorithm
    private_key_extension   = var.private_key_extension
    public_key_extension    = var.public_key_extension
}

module "control_plane_nodes" {
    source              = "./modules/nodes"

    # vsphere 
    datacenter          = var.datacenter
    datastore           = var.datastore
    resource_pool       = var.resource_pool
    dns_domain          = var.dns_domain
    dns_servers         = var.dns_servers
    cluster_name        = var.cluster_name
    vm_folder           = var.vm_folder
    metadata_file       = var.metadata_file
    userdata_file       = var.userdata_file

    # vm
    template            = var.template
    instances           = var.cp_instances
    cpu                 = var.cp_cpu
    ram                 = var.cp_ram
    gateway             = var.cp_gateway
    subnetmask          = var.cp_subnetmask
    network             = var.cp_network
    role_name           = var.cp_role_name

    # Customer Info
    users               = var.users

    # k3s pub key
    k3s_pub_key         = module.private_tls.public_key

}

module "agent_nodes" {
    source              = "./modules/nodes"

    # vsphere 
    datacenter          = var.datacenter
    datastore           = var.datastore
    resource_pool       = var.resource_pool
    dns_domain          = var.dns_domain
    dns_servers         = var.dns_servers
    cluster_name        = var.cluster_name
    vm_folder           = var.vm_folder
    metadata_file       = var.metadata_file
    userdata_file       = var.userdata_file

    # vm
    template            = var.template
    instances           = var.agent_instances
    cpu                 = var.agent_cpu
    ram                 = var.agent_ram
    gateway             = var.agent_gateway
    subnetmask          = var.agent_subnetmask
    network             = var.agent_network
    role_name           = var.worker_role_name

    # Customer Info
    users               = var.users

    # k3s pub key
    k3s_pub_key         = module.private_tls.public_key

}

resource "time_sleep" "node_creation" {
  depends_on = [module.control_plane_nodes,module.agent_nodes]

  create_duration = "60s"
}

module "keepalived" {
  source = "./modules/keepalived"

  distro                  = var.distro == "" ? "ubuntu" : var.distro
  lb_address              = var.lb_address
  control_plane_node_ips  = slice(module.control_plane_nodes.Node-ip, 0, length(module.control_plane_nodes.Node-ip))
  ssh_user                = var.ssh_user
  private_key             = module.private_tls.private_key
  lb_priority             = var.lb_priority
  interface               = var.interface

  depends_on = [time_sleep.node_creation]
}

resource "time_sleep" "keepalived" {
  depends_on = [module.keepalived]

  create_duration = "60s"
}

module "k3s_control_plane" {
    source = "./modules/k3s-control-plane"

    lb_address                          = var.lb_address
    k3s_token                           = random_string.k3s_token.result
    first_control_plane_node_ip         = element(module.control_plane_nodes.Node-ip, 0)
    subsequent_control_plane_node_ips   = slice(module.control_plane_nodes.Node-ip, 1, length(module.control_plane_nodes.Node-ip))
    ssh_user                            = var.ssh_user
    private_key                         = module.private_tls.private_key

    depends_on = [time_sleep.keepalived]
}

resource "time_sleep" "wait_for_control_plane" {
  depends_on = [module.k3s_control_plane]

  create_duration = "60s"
}

module "k3s_agents" {
    source = "./modules/k3s-agents"

    k3s_token                   = random_string.k3s_token.result
    first_control_plane_node_ip = element(module.control_plane_nodes.Node-ip, 0)
    agent_node_ips              = slice(module.agent_nodes.Node-ip, 0, length(module.agent_nodes.Node-ip))
    ssh_user                    = var.ssh_user
    private_key                 = module.private_tls.private_key

    depends_on = [time_sleep.wait_for_control_plane]
}

resource "time_sleep" "wait_for_agents" {
  depends_on = [module.k3s_agents]

  create_duration = "60s"
}

module "kube_config" {
  source                              = "./modules/kubeconfig"
  first_control_plane_node_ip         = element(module.control_plane_nodes.Node-ip, 0)
  lb_address                          = var.lb_address
  ssh_user                            = var.ssh_user
  private_key_name                    = module.private_tls.private_key_filename

  depends_on = [time_sleep.wait_for_agents]
}