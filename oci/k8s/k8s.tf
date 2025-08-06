provider "helm" {
  kubernetes = {
    config_path = "${path.module}/secrets/kubeconfig.yaml"
  }
}

provider "kubernetes" {
  config_path = "${path.module}/secrets/kubeconfig.yaml"
}

resource "helm_release" "cilium" {
  namespace  = "kube-system"
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.18.0"

  set = [
    {
      name  = "hubble.relay.enabled"
      value = "true"
    },
    {
      name  = "hubble.ui.enabled"
      value = "true"
    },
    {
      name  = "ipam.mode"
      value = "kubernetes"
    }
  ]
}

resource "helm_release" "flux-operator" {
  namespace        = "flux-system"
  create_namespace = true
  name             = "flux-operator"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = "0.27.0"
}

resource "kubernetes_secret" "github_auth" {
  depends_on = [
    helm_release.flux-operator
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

resource "helm_release" "flux-instance" {
  depends_on       = [
    helm_release.flux-operator
  ]

  namespace        = "flux-system"
  create_namespace = true
  name             = "flux"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-instance"
  version          = "0.26.0"

  values           = [
    file("${path.module}/../../pve/k8s/values/flux-operator-helm-values.yaml")
  ]

  set = [
    {
      name  = "instance.distribution.version"
      value = var.flux_version
    },
    {
      name  = "instance.distribution.registry"
      value = var.flux_registry
    },
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
    },
    {
      name  = "serviceMonitor.create"
      value = true
    }
  ]
}
