provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = var.account_id
  name          = "sai-b-home"
  config_src    = "cloudflare"
  tunnel_secret = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config = {
    ingress = concat(
      var.mattermost_hostname == "" ? [] : [{
        hostname = var.mattermost_hostname
        service  = "http://mattermost-team-edition.mattermost.svc.cluster.local:8065"
      }],
      var.hermes_hostname == "" ? [] : [{
        hostname = var.hermes_hostname
        service  = "http://hermes-jasonho.agent-pool.svc.cluster.local:9119"
      }],
      [{
        service = "http_status:404"
      }],
    )
  }
}

locals {
  # Only the subnets the laptop needs. 10.0.0.0/24 stays off WARP so a
  # home LAN in that range keeps working. Pod and service CIDRs stay inside
  # the cluster; kubectl uses the API at 10.0.2.5.
  private_routes = {
    workers = "10.0.1.0/24"
    api     = "10.0.2.0/28"
    lb      = "10.0.3.0/24"
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_route" "vcn" {
  for_each = local.private_routes

  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
  network    = each.value
  comment    = "sai-b-home ${each.key}"
}

resource "cloudflare_zero_trust_device_settings" "warp" {
  account_id                = var.account_id
  gateway_proxy_enabled     = true
  gateway_udp_proxy_enabled = true

  lifecycle {
    ignore_changes = [
      disable_for_time,
      external_emergency_signal_enabled,
      external_emergency_signal_fingerprint,
      external_emergency_signal_interval,
      external_emergency_signal_url,
      root_certificate_installation_enabled,
      use_zt_virtual_ip,
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

resource "local_sensitive_file" "tunnel_token" {
  filename        = "${path.module}/generated/tunnel_token"
  content         = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
  file_permission = "0600"
}
