terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "7.21.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.2.1"
    }
  }
}
