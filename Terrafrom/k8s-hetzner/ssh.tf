resource "hcloud_ssh_key" "atlas" {
  name       = "root@atlas"
  public_key = file("${var.ssh_key_atlas_pub}")
}
