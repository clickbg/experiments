
## Update PTR and create A record in CF

resource "hcloud_rdns" "k8s-rdns" {
  count      = var.instances 
  server_id  = hcloud_server.k8s-server[count.index].id
  ip_address = hcloud_server.k8s-server[count.index].ipv4_address
  dns_ptr    = hcloud_server.k8s-server[count.index].name
}

resource "cloudflare_record" "k8s-dns" {
  count      = var.instances 
  zone_id    = var.cloudflare_zone_id
  name       = hcloud_server.k8s-server[count.index].name
  content    = hcloud_server.k8s-server[count.index].ipv4_address
  type       = "A"
  proxied    = false
  ttl        = 300
}
