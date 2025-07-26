provider "proxmox" {
  endpoint  = var.pve_conn_endpoint
  api_token = var.pve_conn_api_token
  insecure  = var.pve_conn_insecure

  ssh {
    agent       = false
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

provider "flux" {
  kubernetes = {
    config_path = "${path.module}/kubeconfig"
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.github_repository}.git"
    http = {
      username = var.github_org
      password = var.github_token
    }
  }
}

provider "kubernetes" {
  config_path    = "${path.module}/kubeconfig"
}
