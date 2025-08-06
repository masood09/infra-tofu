provider "oci" {
  region           = var.oci_region
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}

module "vcn" {
  source                       = "oracle-terraform-modules/vcn/oci"
  version                      = "3.1.0"
  compartment_id               = var.oci_compartment_ocid
  region                       = var.oci_region
  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null
  vcn_name                     = "Free K8s VCN"
  vcn_dns_label                = "freek8svcn"
  vcn_cidrs                    = ["10.1.0.0/16"]
  create_internet_gateway      = true
  create_nat_gateway           = true
  create_service_gateway       = true
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "Free K8s Private Subnet Security List"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.1.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "Free K8s Public Subnet Security List"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.1.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id             = var.oci_compartment_ocid
  vcn_id                     = module.vcn.vcn_id
  cidr_block                 = "10.1.1.0/24"
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [
    oci_core_security_list.private_subnet_sl.id
  ]
  display_name               = "Free K8s Private Subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = module.vcn.vcn_id
  cidr_block        = "10.1.0.0/24"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [
    oci_core_security_list.public_subnet_sl.id
  ]
  display_name      = "Free K8s Public Subnet"
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.oci_compartment_ocid
  kubernetes_version = "v1.33.1"
  name               = "Free K8s Cluster"
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.vcn_public_subnet.id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }

    service_lb_subnet_ids = [oci_core_subnet.vcn_public_subnet.id]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_compartment_ocid
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.oci_compartment_ocid
  kubernetes_version = "v1.33.1"
  name               = "free-k8s-node-pool"
  ssh_public_key     = var.ssh_public_key
  node_shape         = "VM.Standard.A1.Flex"

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    size = 2
  }

  node_shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  node_source_details {
    image_id    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaagb6y5vmiurk2cyrhee74lixe3du42xh4n2e6lquztp3xp32pmfjq"
    source_type = "image"
  }

  initial_node_labels {
    key   = "name"
    value = "free-k8s-cluster"
  }
}

data "oci_containerengine_cluster_kube_config" "k8s_cluster" {
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
}

resource "local_file" "k8s_cluster_kube_config" {
  content  = data.oci_containerengine_cluster_kube_config.k8s_cluster.content
  filename = "${path.module}/../k8s/secrets/kubeconfig.yaml"
}
