output "self_links" {
    value = flatten([
        google_compute_instance.snapshot-masters.*.self_link,
        google_compute_instance.private-snapshot-masters.*.self_link,
    ])
}
