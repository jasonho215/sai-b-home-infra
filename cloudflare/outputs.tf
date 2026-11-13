output "tunnel_id" {
  description = "Remotely managed cloudflared tunnel for the home cluster."
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "private_routes" {
  description = "CIDRs published through the tunnel."
  value       = local.private_routes
}

# Default WARP exclude mode drops all of 10.0.0.0/8. This stack does not
# rewrite that list: the API call replaces every other entry on the profile.
# After the current list is read, delete 10.0.0.0/8 and add the ranges below.
# 10.0.0.0/24 stays excluded so a home LAN there is not sent into the tunnel.
output "split_tunnel_exclude_remove" {
  description = "Delete this entry from the default device profile exclude list."
  value       = "10.0.0.0/8"
}

output "split_tunnel_exclude_add" {
  description = "Add these after removing 10.0.0.0/8. The workers, API, and load-balancer subnets are the gaps."
  value = [
    "10.0.0.0/24",
    "10.0.2.16/28",
    "10.0.2.32/27",
    "10.0.2.64/26",
    "10.0.2.128/25",
    "10.0.4.0/22",
    "10.0.8.0/21",
    "10.0.16.0/20",
    "10.0.32.0/19",
    "10.0.64.0/18",
    "10.0.128.0/17",
    "10.1.0.0/16",
    "10.2.0.0/15",
    "10.4.0.0/14",
    "10.8.0.0/13",
    "10.16.0.0/12",
    "10.32.0.0/11",
    "10.64.0.0/10",
    "10.128.0.0/9",
  ]
}
