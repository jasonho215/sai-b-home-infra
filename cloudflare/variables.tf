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

variable "mattermost_hostname" {
  description = "Public hostname Hermes uses to reach Mattermost. Leave empty until a DNS zone is chosen."
  type        = string
  default     = ""
}
