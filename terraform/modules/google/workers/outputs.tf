output "self_links" {
    value = flatten([
        google_compute_instance.workers.*.self_link,
        google_compute_instance.private-workers.*.self_link,
    ])
}
