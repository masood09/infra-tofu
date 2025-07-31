// Create the  flux-system namespace.
resource "kubernetes_namespace" "flux-system" {
  depends_on = [
    talos_machine_bootstrap.bootstrap,
    data.talos_cluster_health.health,
    local_file.kubeconfig
  ]

  metadata {
    name   = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

// Create a Kubernetes secret with the GitHub credentials
resource "kubernetes_secret" "github-auth" {
  depends_on = [
    kubernetes_namespace.flux-system
  ]

  metadata {
    name      = "github-auth"
    namespace = "flux-system"
  }

  data = {
    username = var.github_org
    password = var.github_token
  }

  type = "Opaque"
}

// Create a Kubernetes secret with the Age Private Key
resource "kubernetes_secret" "sops-age" {
  depends_on = [
    kubernetes_namespace.flux-system
  ]

  metadata {
    name         = "sops-age"
    namespace    = "flux-system"
  }

  data = {
    "age.agekey" = file("${path.module}/age-key.txt")
  }
}

// Install the Flux Operator.
resource "helm_release" "flux-operator" {
  depends_on = [
    kubernetes_namespace.flux-system,
    local_file.kubeconfig
  ]

  name       = "flux-operator"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  wait       = true
}

// Configure the Flux instance.
resource "helm_release" "flux_instance" {
  depends_on = [
    helm_release.flux-operator,
    kubernetes_namespace.flux-system,
    kubernetes_secret.github-auth,
    kubernetes_secret.sops-age
  ]

  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"

  // Configure the Flux components and kustomize patches.
  values = [
    file("values/flux-operator-helm-values.yaml")
  ]

  // Configure the Flux distribution.
  set = [
    {
      name  = "instance.distribution.version"
      value = var.flux_version
    },
    {
      name  = "instance.distribution.registry"
      value = var.flux_registry
    },
    // Configure Flux Git sync.
    {
      name  = "instance.sync.kind"
      value = "GitRepository"
    },
    {
      name  = "instance.sync.url"
      value = "https://github.com/${var.github_org}/${var.github_repository}.git"
    },
    {
      name  = "instance.sync.path"
      value = var.git_sync_path
    },
    {
      name  = "instance.sync.ref"
      value = "refs/heads/main"
    },
    {
      name  = "instance.sync.provider"
      value = "generic"
    },
    {
      name  = "instance.sync.pullSecret"
      value = "github-auth"
    }
  ]
}
