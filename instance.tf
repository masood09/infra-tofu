data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_compartment_ocid
}

data "oci_core_images" "vm_images" {
  compartment_id = var.oci_compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape = "VM.Standard.A1.Flex"
}

resource "oci_core_instance" "oci-auth-server_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-auth-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-auth-server"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "oci-vpn-server_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-vpn-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-vpn-server"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "ldap-server_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "ldap-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "ldap-server"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
