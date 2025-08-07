provider "oci" {
  region           = var.oci_region
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}

module "vcn" {
  source                       = "oracle-terraform-modules/vcn/oci"
  version                      = "3.6.0"
  compartment_id               = var.oci_compartment_ocid
  region                       = var.oci_region
  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null
  vcn_name                     = "K8s VCN"
  vcn_dns_label                = "k8svcn"
  vcn_cidrs                    = ["172.16.0.0/16"]
  create_internet_gateway      = true
  create_nat_gateway           = true
  create_service_gateway       = true
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "K8s Private Subnet Security List"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "172.16.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "K8s Public Subnet Security List"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "172.16.0.0/16"
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
  cidr_block                 = "172.16.1.0/24"
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [
    oci_core_security_list.private_subnet_sl.id
  ]
  display_name               = "K8s Private Subnet"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "privatesubnet"
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = module.vcn.vcn_id
  cidr_block        = "172.16.0.0/24"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [
    oci_core_security_list.public_subnet_sl.id
  ]
  display_name      = "K8s Public Subnet"
  dns_label         = "publicsubnet"
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.oci_compartment_ocid
  kubernetes_version = "v1.33.1"
  name               = "K8s Cluster"
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.vcn_public_subnet.id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    kubernetes_network_config {
      pods_cidr     = "10.240.0.0/16"
      services_cidr = "10.250.0.0/16"
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
  name               = "k8s-node-pool"
  ssh_public_key     = var.ssh_public_key
  node_shape         = "VM.Standard.A1.Flex"

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    size = 3
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
    value = "k8s-cluster"
  }
}

resource "oci_bastion_bastion" "k8s_bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.oci_compartment_ocid
  target_subnet_id             = oci_core_subnet.vcn_private_subnet.id
  name                         = "K8SBastion"

  client_cidr_block_allow_list = [
    "0.0.0.0/0"
  ]
}

resource "oci_bastion_session" "k8s_session" {
  depends_on             = [
    oci_containerengine_node_pool.k8s_node_pool
  ]

  bastion_id             = oci_bastion_bastion.k8s_bastion.id
  display_name           = "tofu-bastion-session"
  session_ttl_in_seconds = 3600

  key_details {
    public_key_content = var.ssh_public_key
  }

  target_resource_details {
    session_type                       = "PORT_FORWARDING"
    target_resource_port               = 6443
    target_resource_private_ip_address = split(":", oci_containerengine_cluster.k8s_cluster.endpoints[0].private_endpoint)[0]
  }
}

data "oci_containerengine_cluster_kube_config" "k8s_cluster" {
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
}

resource "local_file" "k8s_cluster_kube_config" {
  content  = data.oci_containerengine_cluster_kube_config.k8s_cluster.content
  filename = "${path.module}/../k8s/secrets/kubeconfig.yaml"
}

output "ssh-port-forward-command" {
  value = oci_bastion_session.k8s_session.ssh_metadata.command
}
