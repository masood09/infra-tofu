data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_compartment_ocid
}

data "oci_core_images" "vm_images" {
  compartment_id = var.oci_compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape = "VM.Standard.A1.Flex"
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
    # source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
    source_id = "ocid1.image.oc1.ca-toronto-1.aaaaaaaapdi7nd6nmef5o26mqzcvpyhsygucqn6zrxdvkpy2w34g3culh4vq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "accesscontrolsystem_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "accesscontrolsystem"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "accesscontrolsystem"
  }

  source_details {
    source_type = "image"
    # source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
    source_id = "ocid1.image.oc1.ca-toronto-1.aaaaaaaapdi7nd6nmef5o26mqzcvpyhsygucqn6zrxdvkpy2w34g3culh4vq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "meshcontrol_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "meshcontrol"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "meshcontrol"
  }

  source_details {
    source_type = "image"
    # source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
    source_id = "ocid1.image.oc1.ca-toronto-1.aaaaaaaapdi7nd6nmef5o26mqzcvpyhsygucqn6zrxdvkpy2w34g3culh4vq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

resource "oci_core_instance" "watchfulsystem_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  display_name        = "watchfulsystem"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn_public_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "watchfulsystem"
  }

  source_details {
    source_type = "image"
    # source_id   = lookup(data.oci_core_images.vm_images.images[0], "id")
    source_id = "ocid1.image.oc1.ca-toronto-1.aaaaaaaapdi7nd6nmef5o26mqzcvpyhsygucqn6zrxdvkpy2w34g3culh4vq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
