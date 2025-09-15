
## VM creation

resource "hcloud_server" "k8s-server" {
  count                      = var.instances
  name                       = "node${count.index + 1}.${var.domain}"
  image                      = var.os_type
  server_type                = var.server_type
  location                   = var.location
  ssh_keys                   = [hcloud_ssh_key.k8s-server.name]
  allow_deprecated_images    = false
  shutdown_before_deletion   = false
  backups                    = false
  ignore_remote_firewall_ids = false
  rebuild_protection         = false
  delete_protection          = false
  keep_disk                  = false
  placement_group_id         = hcloud_placement_group.k8s-placement-group.id
  firewall_ids               = [hcloud_firewall.k8s-firewall.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  labels = {
    type = "k8s"
  }

  network {
    network_id = hcloud_network.k8s-private-network.id
  }
 
  provisioner "local-exec" {
    command = "echo ${self.name} : ${self.ipv4_address} >> inventory.txt"
  }

  provisioner "local-exec" {
    command     = "sed -i '/${self.name}/d' inventory.txt"
    when        = destroy
    on_failure  = continue
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=\"False\" ANSIBLE_CONFIG=\"ansible/ansible.cfg\" ansible-playbook -u ${var.ssh_user} --private-key=${var.ssh_key_priv} --extra-vars='k8s_version=${var.k8s_version}' -i '${self.ipv4_address},' ansible/k8s-setup.yaml"
  }

  depends_on = [
    hcloud_network_subnet.k8s-private-subnet,
    hcloud_placement_group.k8s-placement-group,
    hcloud_firewall.k8s-firewall,
  ]
 
}
