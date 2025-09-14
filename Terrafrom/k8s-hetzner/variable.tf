variable "HCLOUD_TOKEN" {}

variable "CF_TOKEN" {}

variable "cloudflare_zone_id" {
  default = "<ENTER YOUR DOMAIN ZONE ID HERE>"
}

variable "ssh_key_atlas_pub" {
  default = "/root/.ssh/id_rsa.pub"
}

variable "ssh_key_atlas_priv" {
  default = "/root/.ssh/id_rsa"
}

variable "domain" {
  default = "<ENTER YOUR DOMAIN HERE>"
}

variable "k8s_version" {
  default = "v1.34"
}
 
variable "location" {
  default = "fsn1"
}
 
variable "instances" {
  default = "3"
}
 
variable "server_type" {
  default = "cx22"
}
 
variable "os_type" {
  default = "ubuntu-24.04"
}

variable "private_network_location" {
  default = "eu-central"
}

variable "private_network_cidr" {
  default = "10.170.0.0/24"
}

variable "firewall_allowed_networks" {
  type        = list(string)
  default     = [
    "<ENTER_YOUR_IP_HERE>/32",
    "10.170.0.0/24",
   ]
}

