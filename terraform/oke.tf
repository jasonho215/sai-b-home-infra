resource "tls_private_key" "workers" {
  algorithm = "ED25519"
}

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = local.name
  vcn_id             = oci_core_vcn.this.id
  type               = "BASIC_CLUSTER"

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.api.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.lb.id]

    kubernetes_network_config {
      pods_cidr     = local.pods_cidr
      services_cidr = local.services_cidr
    }
  }
}

resource "oci_containerengine_node_pool" "workers" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.this.id
  kubernetes_version = var.kubernetes_version
  name               = "${local.name}-e4"
  node_shape         = "VM.Standard.E4.Flex"
  ssh_public_key     = tls_private_key.workers.public_key_openssh

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = local.node_image_id
    boot_volume_size_in_gbs = 50
  }

  node_config_details {
    size = 2

    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = oci_core_subnet.workers.id
    }
  }

  depends_on = [oci_identity_policy.workers]
}

resource "oci_bastion_bastion" "this" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.workers.id
  name                         = local.name
  client_cidr_block_allow_list = [var.bastion_client_cidr]
  max_session_ttl_in_seconds   = 10800
}

data "oci_containerengine_cluster_kube_config" "this" {
  cluster_id = oci_containerengine_cluster.this.id
  endpoint   = "PRIVATE_ENDPOINT"
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.module}/generated/kubeconfig"
  content  = data.oci_containerengine_cluster_kube_config.this.content
}

resource "local_sensitive_file" "worker_ssh_key" {
  filename        = "${path.module}/generated/worker_ed25519"
  content         = tls_private_key.workers.private_key_openssh
  file_permission = "0600"
}

resource "random_password" "mattermost_db" {
  length  = 32
  special = false
}

resource "local_sensitive_file" "mattermost_db_password" {
  filename        = "${path.module}/generated/mattermost_db_password"
  content         = random_password.mattermost_db.result
  file_permission = "0600"
}
