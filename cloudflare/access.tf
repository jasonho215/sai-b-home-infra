# Gateway posture matches devices enrolled in this Zero Trust organization.
# The consumer WARP client does not pass this check.
resource "cloudflare_zero_trust_device_posture_rule" "gateway" {
  account_id = var.account_id
  name       = "sai-b-home-gateway"
  type       = "gateway"
}

# Mattermost and the API use the same posture check today, but the policies
# stay separate so a later service can be allowed onto Mattermost alone.
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

resource "cloudflare_zero_trust_access_policy" "hermes" {
  account_id = var.account_id
  name       = "sai-b-home hermes enrolled devices"
  decision   = "allow"

  include = [{
    device_posture = {
      integration_uid = cloudflare_zero_trust_device_posture_rule.gateway.id
    }
  }]
}

resource "cloudflare_zero_trust_access_policy" "kubernetes" {
  account_id = var.account_id
  name       = "sai-b-home kubernetes enrolled devices"
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

resource "cloudflare_zero_trust_access_application" "hermes" {
  account_id                  = var.account_id
  name                        = "hermes-jasonho"
  domain                      = var.hermes_hostname
  type                        = "self_hosted"
  session_duration            = "24h"
  allow_authenticate_via_warp = true
  auto_redirect_to_identity   = false

  policies = [{
    id         = cloudflare_zero_trust_access_policy.hermes.id
    precedence = 1
  }]
}

# Private destination. Access denies this port unless the kubernetes policy
# matches, even when the device is already enrolled and the tunnel route exists.
# Worker and load-balancer routes are not covered by this application.
resource "cloudflare_zero_trust_access_application" "kubernetes" {
  account_id                  = var.account_id
  name                        = "kubernetes-api"
  type                        = "self_hosted"
  session_duration            = "24h"
  app_launcher_visible        = false
  allow_authenticate_via_warp = true
  auto_redirect_to_identity   = false

  destinations = [{
    type        = "private"
    cidr        = local.private_routes.api
    port_range  = "6443"
    l4_protocol = "tcp"
  }]

  policies = [{
    id         = cloudflare_zero_trust_access_policy.kubernetes.id
    precedence = 1
  }]
}

resource "cloudflare_dns_record" "hermes" {
  zone_id = var.zone_id
  name    = var.hermes_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
  comment = "Hermes dashboard, reachable only by enrolled WARP devices"
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
