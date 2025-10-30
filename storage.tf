resource "oci_objectstorage_bucket" "oci-restic-postgresql_bucket" {
  compartment_id = var.oci_compartment_ocid
  name           = "oci-restic-backup"
  namespace      = var.oci_object_storage_namespace
}
