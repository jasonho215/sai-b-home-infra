# Credentials come from the OCI CLI config (~/.oci/config).
# Precedence is environment variables, then this profile, then DEFAULT.
provider "oci" {
  region              = var.region
  config_file_profile = var.config_file_profile
}
