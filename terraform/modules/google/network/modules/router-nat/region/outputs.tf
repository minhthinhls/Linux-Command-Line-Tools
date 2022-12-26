output "address" {
    value = google_compute_address.this.*.address
}

output "router" {
    value = google_compute_router.this
}

output "router_nat" {
    value = google_compute_router_nat.this
}
