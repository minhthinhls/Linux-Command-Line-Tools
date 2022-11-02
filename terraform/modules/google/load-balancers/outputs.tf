output "self_links" {
    value = flatten([
        google_compute_instance.load-balancers.*.self_link,
        google_compute_instance.private-load-balancers.*.self_link,
    ])
}
