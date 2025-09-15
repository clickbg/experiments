resource "hcloud_ssh_key" "k8s-server" {
  name       = "root@remote"
  public_key = file("${var.ssh_key_pub}")
}
