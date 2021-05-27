#cloud-config
users:
  - name: k3s-user
    ssh-authorized-keys:
      - ${k3s_pub_key}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
%{ for name, pub_keys in users ~}
  - name: ${name}
    ssh-authorized-keys:
%{ for pub_key in pub_keys ~}
      - ${pub_key}
%{ endfor ~}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
%{ endfor ~}