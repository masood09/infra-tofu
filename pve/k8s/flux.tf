resource "kubernetes_namespace" "flux-system" {
  depends_on = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health, local_file.kubeconfig ]

  metadata {
    name   = "flux-system"

    labels = {
      "app.kubernetes.io/instance"            = "flux-system"
      "app.kubernetes.io/part-of"             = "flux"
      "app.kubernetes.io/version"             = "v2.6.4"
      "kustomize.toolkit.fluxcd.io/name"      = "flux-system"
      "kustomize.toolkit.fluxcd.io/namespace" = "flux-system"
    }
  }
}

resource "kubernetes_secret" "sops-age" {
  depends_on = [ kubernetes_namespace.flux-system ]

  metadata {
    name         = "sops-age"
    namespace    = "flux-system"
  }

  data = {
    "age.agekey" = file("${path.module}/age-key.txt")
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on         = [ kubernetes_namespace.flux-system, kubernetes_secret.sops-age ]
  embedded_manifests = true
  path               = "clusters/homelab-staging"
}
