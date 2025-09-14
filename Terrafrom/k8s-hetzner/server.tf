
## VM creation

resource "hcloud_server" "k8s-server" {
  count                      = var.instances
  name                       = "node${count.index + 1}.${var.domain}"
  image                      = var.os_type
  server_type                = var.server_type
  location                   = var.location
  ssh_keys                   = [hcloud_ssh_key.atlas.name]
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
    command     = "sed -i '/${self.name}/d' ./inventory.txt"
    when        = destroy
    on_failure  = continue
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y -o Dpkg::Options::='--force-confnew' dist-upgrade",
      "sudo apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates ebtables ethtool",
      "sudo echo 'overlay' > /etc/modules-load.d/k8s.conf",
      "sudo echo 'br_netfilter' >> /etc/modules-load.d/k8s.conf",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "sudo echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/k8s.conf",
      "sudo echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/k8s.conf",
      "sudo echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/k8s.conf",
      "sudo sysctl -p /etc/sysctl.d/k8s.conf",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/${var.k8s_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg /etc/apt/keyrings/docker.asc",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${var.k8s_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu '$(grep UBUNTU_CODENAME /etc/os-release | cut -d '=' -f2)' stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/docker.list",
      "sudo apt-get update",
      "sudo apt-get -y install kubelet kubeadm kubectl containerd.io",
      "apt-mark hold kubelet kubeadm kubectl",
      "sudo mkdir -p /etc/containerd",
      "sudo containerd config default>/etc/containerd/config.toml",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml",
      "sudo systemctl enable containerd",
      "sudo systemctl restart containerd",
      "sudo curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz",
      "sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin",
      "sudo rm -f cilium-linux-amd64.tar.gz",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("${var.ssh_key_atlas_priv}")
      host        = self.ipv4_address
      timeout     = "5m"
    }
  }

  depends_on = [
    hcloud_network_subnet.k8s-private-subnet,
    hcloud_placement_group.k8s-placement-group,
    hcloud_firewall.k8s-firewall,
  ]
 
}
