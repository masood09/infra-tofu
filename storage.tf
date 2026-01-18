resource "oci_objectstorage_bucket" "backups" {
  compartment_id = var.oci_compartment_ocid
  name           = "backups"
  namespace      = var.oci_object_storage_namespace
}
