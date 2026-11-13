resource "oci_identity_dynamic_group" "workers" {
  compartment_id = var.tenancy_ocid
  name           = "${local.name}-oke-workers"
  description    = "Worker nodes of the sai-b-home basic OKE cluster."
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "workers" {
  compartment_id = var.tenancy_ocid
  name           = "${local.name}-oke-workers"
  description    = "Instance principal rights for the OKE cloud controller and block-volume CSI driver."

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.workers.name} to manage volume-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.workers.name} to use virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.workers.name} to use instance-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.workers.name} to read cluster-family in compartment id ${var.compartment_ocid}",
  ]
}
