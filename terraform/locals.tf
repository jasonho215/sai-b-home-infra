locals {
  name                = "sai-b-home"
  vcn_cidr            = "10.0.0.0/16"
  worker_cidr         = "10.0.1.0/24"
  api_cidr            = "10.0.2.0/28"
  lb_cidr             = "10.0.3.0/24"
  pods_cidr           = "10.244.0.0/16"
  services_cidr       = "10.96.0.0/16"
  osn_service         = data.oci_core_services.osn.services[0]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  node_image_id = one([
    for source in data.oci_containerengine_node_pool_option.images.sources :
    source.image_id if source.source_name == var.node_image_name
  ])
}
