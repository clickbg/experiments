
## VM firewall

resource "hcloud_firewall" "k8s-firewall" {
  name = "k8s-firewall"

  rule {
    description = "ALLOW: All from trusted networks (TCP)"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips  = var.firewall_allowed_networks
  }

  rule {
    description = "ALLOW: All from trusted networks (UDP)"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips  = var.firewall_allowed_networks
  }

  rule {
    description = "ALLOW: All from trusted networks (ICMP)"
    direction   = "in"
    protocol    = "icmp"
    source_ips  = var.firewall_allowed_networks
  }

}
