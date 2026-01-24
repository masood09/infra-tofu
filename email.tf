resource "oci_email_email_domain" "mantannest_com" {
  compartment_id = var.oci_compartment_ocid
  name = "mantannest.com"
  description = "Managed by OpenTofu"
}

resource "oci_email_dkim" "mantannest_com" {
  email_domain_id = oci_email_email_domain.mantannest_com.id
  description = "Managed by OpenTofu"
  name = "oci-catoronto-1"
}

resource "oci_email_sender" "auth" {
  compartment_id = var.oci_compartment_ocid
  email_address = "auth@mantannest.com"
}

resource "oci_email_sender" "passwords" {
  compartment_id = var.oci_compartment_ocid
  email_address = "passwords@mantannest.com"
}

resource "oci_email_sender" "photos" {
  compartment_id = var.oci_compartment_ocid
  email_address = "photos@mantannest.com"
}

