output "network_load_balancers_ipv4" {
    value = google_compute_forwarding_rule.this.*.ip_address
}
