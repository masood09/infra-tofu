resource "oci_identity_dynamic_group" "vault_access" {
  compartment_id = var.oci_compartment_ocid
  matching_rule  = "ANY {instance.compartment.id = '${var.oci_compartment_ocid}'}"
  name           = "vault-access-group"
  description    = "Dynamic group for Vault access"
}

resource "oci_identity_policy" "vault_access" {
  name           = "vault-access"
  description    = "Policy for Vault access"
  compartment_id = var.oci_compartment_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access.name} to manage vaults in compartment id ${var.oci_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access.name} to manage keys in compartment id ${var.oci_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access.name} to manage secret-family in compartment id ${var.oci_compartment_ocid}",
  ]
}
