data "helm_template" "cilium" {
  namespace    = "kube-system"
  name         = "cilium"
  repository   = "https://helm.cilium.io"
  chart        = "cilium"
  # renovate: datasource=helm depName=cilium registryUrl=https://helm.cilium.io
  version      = "1.18.0"
  kube_version = var.kubernetes_version
  set = [
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
    {
      name  = "kubeProxyReplacement"
      value = "true"
    },
    {
      name  = "securityContext.capabilities.ciliumAgent"
      value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
    },
    {
      name  = "securityContext.capabilities.cleanCiliumState"
      value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
    },
    {
      name  = "cgroup.autoMount.enabled"
      value = "false"
    },
    {
      name  = "cgroup.hostRoot"
      value = "/sys/fs/cgroup"
    },
    {
      name  = "k8sServiceHost"
      value = "localhost"
    },
    {
      name  = "k8sServicePort"
      value = "7445"
    },
    {
      name  = "hubble.relay.enabled"
      value = "true"
    },
    {
      name  = "hubble.ui.enabled"
      value = "true"
    }
  ]
}

data "helm_template" "flux-operator" {
  namespace    = "flux-system"
  name         = "flux-operator"
  repository   = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart        = "flux-operator"
  # renovate: datasource=docker depName=flux-operator registryUrl=ghcr.io/controlplaneio-fluxcd/charts
  version      = "0.26.0"
  kube_version = var.kubernetes_version
}

data "helm_template" "flux-instance" {
  namespace    = "flux-system"
  name         = "flux"
  repository   = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart        = "flux-instance"
  # renovate: datasource=docker depName=flux-instance registryUrl=ghcr.io/controlplaneio-fluxcd/charts
  version      = "0.26.0"
  kube_version = var.kubernetes_version
  values       = [
    file("values/flux-operator-helm-values.yaml")
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
    },
    {
      name  = "serviceMonitor.create"
      value = true
    }
  ]
}
