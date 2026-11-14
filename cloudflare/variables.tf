variable "cloudflare_api_token" {
  description = "API token with Cloudflare Tunnel Write and Zero Trust Write on this account."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account that owns the Zero Trust organization."
  type        = string
  default     = "e3108199d8c3ee04b18bf1b0a2ab79a2"
}

variable "zone_id" {
  description = "Cloudflare zone for cowzaap.dev."
  type        = string
  default     = "d7b875a504ad4965d682a60a2ccd5594"
}

variable "mattermost_hostname" {
  description = "Hostname published through the tunnel. Access allows only devices enrolled in this Zero Trust organization."
  type        = string
  default     = "mattermost.cowzaap.dev"
}
