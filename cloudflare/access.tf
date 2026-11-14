# Gateway posture matches devices enrolled in this Zero Trust organization.
# The consumer WARP client does not pass this check.
resource "cloudflare_zero_trust_device_posture_rule" "gateway" {
  account_id = var.account_id
  name       = "sai-b-home-gateway"
  type       = "gateway"
}

resource "cloudflare_zero_trust_access_policy" "mattermost" {
  account_id = var.account_id
  name       = "sai-b-home mattermost enrolled devices"
  decision   = "allow"

  include = [{
    device_posture = {
      integration_uid = cloudflare_zero_trust_device_posture_rule.gateway.id
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "mattermost" {
  account_id                  = var.account_id
  name                        = "mattermost"
  domain                      = var.mattermost_hostname
  type                        = "self_hosted"
  session_duration            = "24h"
  allow_authenticate_via_warp = true
  auto_redirect_to_identity   = false

  policies = [{
    id         = cloudflare_zero_trust_access_policy.mattermost.id
    precedence = 1
  }]
}

resource "cloudflare_dns_record" "mattermost" {
  zone_id = var.zone_id
  name    = var.mattermost_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
  comment = "Mattermost, reachable only by enrolled WARP devices"
}
