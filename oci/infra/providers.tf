terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "7.20.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
