! Configuration File for keepalived

global_defs {
}

vrrp_instance VI_1 {
    state MASTER
    interface ${interface}
    virtual_router_id ${router_id}
    priority ${lb_priority}
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ${lb_password}
    }
    virtual_ipaddress {
        ${lb_address}
    }
}