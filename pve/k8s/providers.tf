terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.80.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}
