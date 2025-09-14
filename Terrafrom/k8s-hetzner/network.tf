
## VM private networking

resource "hcloud_network" "k8s-private-network" {
  name     = "k8s-private-network"
  ip_range = "10.0.0.0/8"
  labels = {
    key = "k8s"
  }
} 
resource "hcloud_network_subnet" "k8s-private-subnet" {
  network_id   = hcloud_network.k8s-private-network.id
  type         = "cloud"
  network_zone = var.private_network_location
  ip_range     = var.private_network_cidr
}
