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

data "sops_file" "prod_flux_discord_webhook" {
  source_file = "${path.module}/secrets/prod-flux-discord-webhook.enc.json"
}

resource "oci_vault_secret" "prod_flux_discord_webhook" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "prod-flux-discord-webhook"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.prod_flux_discord_webhook.raw)
  }
}

data "sops_file" "prod_cloudflare_token" {
  source_file = "${path.module}/secrets/prod-cloudflare-token.enc.json"
}

resource "oci_vault_secret" "prod_cloudflare_token" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "prod-cloudflare-token"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.prod_cloudflare_token.raw)
  }
}

data "sops_file" "prod_traefik_dashboard_auth" {
  source_file = "${path.module}/secrets/prod-traefik-dashboard-auth.enc.json"
}

resource "oci_vault_secret" "prod_traefik_dashboard_auth" {
  compartment_id = var.oci_compartment_ocid
  key_id         = oci_kms_key.oci_vault_key.id
  secret_name    = "prod-traefik-dashboard-auth"
  vault_id       = oci_kms_vault.oci_vault.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(data.sops_file.prod_traefik_dashboard_auth.raw)
  }
}
