data "oci_identity_compartment" "target" {
  id = var.compartment_ocid
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "osn" {
  filter {
    name   = "name"
    values = ["^All .* Services In Oracle Services Network$"]
    regex  = true
  }
}

data "oci_containerengine_node_pool_option" "images" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_ocid
}
