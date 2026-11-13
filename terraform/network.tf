resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [local.vcn_cidr]
  display_name   = "${local.name}-vcn"
  dns_label      = "saibhome"
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-nat"
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-sgw"

  services {
    service_id = local.osn_service.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
    description       = "Internet egress for image pulls and Cloudflare Tunnel"
  }

  route_rules {
    destination       = local.osn_service.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
    description       = "Oracle Services Network"
  }
}

resource "oci_core_security_list" "workers" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-workers"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Worker egress. Stateful, so return traffic is allowed."
  }

  ingress_security_rules {
    source      = local.vcn_cidr
    protocol    = "all"
    description = "VCN to workers, including the API endpoint and OCI Bastion."
  }

  ingress_security_rules {
    source      = local.pods_cidr
    protocol    = "all"
    description = "Flannel pod overlay to nodes."
  }
}

resource "oci_core_security_list" "api" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-api"

  egress_security_rules {
    destination = local.osn_service.cidr_block
    protocol    = "6"
    description = "API endpoint to OKE"

    destination_type = "SERVICE_CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    destination = local.worker_cidr
    protocol    = "6"
    description = "API endpoint to workers (Flannel)"
  }

  ingress_security_rules {
    source      = local.worker_cidr
    protocol    = "6"
    description = "Workers and in-cluster cloudflared to the API"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    source      = local.worker_cidr
    protocol    = "6"
    description = "Workers to the API webhook port"

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    source      = local.worker_cidr
    protocol    = "1"
    description = "Path MTU discovery"

    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name}-lb"

  egress_security_rules {
    destination = local.worker_cidr
    protocol    = "6"
    description = "Private load balancer to workers, if one is created later"
  }
}

resource "oci_core_subnet" "workers" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.worker_cidr
  display_name               = "${local.name}-workers"
  dns_label                  = "workers"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.workers.id]
}

resource "oci_core_subnet" "api" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.api_cidr
  display_name               = "${local.name}-api"
  dns_label                  = "api"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.api.id]
}

resource "oci_core_subnet" "lb" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.lb_cidr
  display_name               = "${local.name}-lb"
  dns_label                  = "lb"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.lb.id]
}
