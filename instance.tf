data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_compartment_ocid
}

data "oci_core_images" "vm_images" {
  compartment_id = var.oci_compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape = "VM.Standard.A1.Flex"
}

resource "oci_core_instance" "oci-server1_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-server1"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-server1"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "oci-server2_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-server2"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-server2"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "oci-server3_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-server3"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-server3"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "oci-server4_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-server4"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-server4"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
