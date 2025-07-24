resource "flux_bootstrap_git" "this" {
  depends_on         = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health, local_file.kubeconfig ]
  embedded_manifests = true
  path               = "clusters/homelab-staging"
}
