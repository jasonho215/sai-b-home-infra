variable "region" {
  description = "OCI region for this stack. Example: us-ashburn-1."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment that owns provisioned resources."
  type        = string
}

variable "config_file_profile" {
  description = "Profile name in the OCI CLI config file (~/.oci/config)."
  type        = string
  default     = "DEFAULT"
}

variable "tenancy_ocid" {
  description = "OCID of the tenancy. Required for availability domains and worker instance-principal policies."
  type        = string
}

variable "bastion_client_cidr" {
  description = "IPv4 CIDR allowed to open OCI Bastion sessions. Use a /32 of the admin workstation."
  type        = string
}

variable "kubernetes_version" {
  description = "OKE Kubernetes version. v1.36.4 is the newest non-preview release in ap-singapore-2."
  type        = string
  default     = "v1.36.4"
}

variable "node_image_name" {
  description = "x86_64 OKE node image source name. Must match kubernetes_version."
  type        = string
  default     = "Oracle-Linux-9.8-2026.10.16-0-OKE-1.36.4-2067"
}
