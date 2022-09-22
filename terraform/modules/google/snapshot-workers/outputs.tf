output "self_links" {
    value = flatten([
        google_compute_instance.snapshot-workers.*.self_link,
        google_compute_instance.private-snapshot-workers.*.self_link,
    ])
}
