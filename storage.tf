resource "oci_objectstorage_bucket" "oci-restic-auth-server" {
  compartment_id = var.oci_compartment_ocid
  name           = "oci-restic-auth-server"
  namespace      = var.oci_object_storage_namespace
}

resource "oci_objectstorage_bucket" "oci-restic-vpn-server" {
  compartment_id = var.oci_compartment_ocid
  name           = "oci-restic-vpn-server"
  namespace      = var.oci_object_storage_namespace
}
