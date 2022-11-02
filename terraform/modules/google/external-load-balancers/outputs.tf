output "network_load_balancers_ipv4" {
    value = google_compute_forwarding_rule.external_network_load_balancer.*.ip_address
}
