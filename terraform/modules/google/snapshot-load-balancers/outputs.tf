output "self_links" {
    value = flatten([
        google_compute_instance.snapshot-load-balancers.*.self_link,
        google_compute_instance.private-snapshot-load-balancers.*.self_link,
    ])
}
