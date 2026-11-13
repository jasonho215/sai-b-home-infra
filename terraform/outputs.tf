output "compartment_name" {
  description = "Name of the compartment this stack targets."
  value       = data.oci_identity_compartment.target.name
}

output "compartment_ocid" {
  description = "OCID of the compartment this stack targets."
  value       = data.oci_identity_compartment.target.id
}

output "cluster_id" {
  description = "OCID of the basic OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "kubernetes_api_endpoint" {
  description = "Private Kubernetes API address. Reachable through WARP or an OCI Bastion tunnel."
  value       = oci_containerengine_cluster.this.endpoints[0].private_endpoint
}

output "bastion_id" {
  description = "OCID of the OCI Bastion used to bootstrap the private API."
  value       = oci_bastion_bastion.this.id
}

output "worker_subnet_id" {
  description = "Subnet that contains the ARM worker nodes."
  value       = oci_core_subnet.workers.id
}

output "vcn_cidr" {
  description = "CIDR to publish on the Cloudflare Tunnel for WARP clients."
  value       = local.vcn_cidr
}
