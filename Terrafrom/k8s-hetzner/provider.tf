terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
 
provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

provider "cloudflare" {
  api_token = var.CF_TOKEN
}
