output "self_links" {
    value = flatten([
        google_compute_instance.masters.*.self_link,
        google_compute_instance.private-masters.*.self_link,
    ])
}
