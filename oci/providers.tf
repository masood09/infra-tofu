terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "8.2.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.3.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.18.0"
    }
  }
}

provider "oci" {
  region           = var.oci_region
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
