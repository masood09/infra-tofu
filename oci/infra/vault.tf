provider "sops" {}

resource "oci_kms_vault" "oci_vault" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "OCI Vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "oci_vault_key" {
  compartment_id      = var.oci_compartment_ocid
  display_name        = "OCI Vault Key"
  management_endpoint = oci_kms_vault.oci_vault.management_endpoint

  key_shape {
    algorithm = "AES"
    length    = "32"
  }
}

data "sops_file" "flux-discord-webhook" {
  source_file = "${path.module}/secrets/flux-discord-webhook.enc.json"
}

resource "oci_vault_secret" "flux-discord-webhook" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "flux-discord-webhook"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.flux-discord-webhook.raw)
  }
}

data "sops_file" "cloudflare-token" {
  source_file = "${path.module}/secrets/cloudflare-token.enc.json"
}

resource "oci_vault_secret" "cloudflare-token" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "cloudflare-token"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.cloudflare-token.raw)
  }
}

data "sops_file" "traefik-dashboard-auth" {
  source_file = "${path.module}/secrets/traefik-dashboard-auth.enc.json"
}

resource "oci_vault_secret" "traefik-dashboard-auth" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "traefik-dashboard-auth"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.traefik-dashboard-auth.raw)
  }
}
