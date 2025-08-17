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

data "sops_file" "flux_discord_webhook" {
  source_file = "${path.module}/secrets/flux-discord-webhook.enc.json"
}

resource "oci_vault_secret" "flux_discord_webhook" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "flux-discord-webhook"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.flux_discord_webhook.raw)
  }
}

data "sops_file" "cloudflare_token" {
  source_file = "${path.module}/secrets/cloudflare-token.enc.json"
}

resource "oci_vault_secret" "cloudflare_token" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "cloudflare-token"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.cloudflare_token.raw)
  }
}

data "sops_file" "traefik_dashboard_auth" {
  source_file = "${path.module}/secrets/traefik-dashboard-auth.enc.json"
}

resource "oci_vault_secret" "traefik_dashboard_auth" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "traefik-dashboard-auth"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.traefik_dashboard_auth.raw)
  }
}
