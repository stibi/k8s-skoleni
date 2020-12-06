provider "digitalocean" {
  token = chomp(file("~/.config/digital-ocean/token"))
}

provider "ct" {}

terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.6.1"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "1.22.1"
    }
  }
}

