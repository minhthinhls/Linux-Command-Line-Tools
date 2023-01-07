output "network_load_balancers_ipv4" {
    value = flatten([
        [for key, forwarding_rule in google_compute_forwarding_rule.this : forwarding_rule.ip_address],
    ])
}
