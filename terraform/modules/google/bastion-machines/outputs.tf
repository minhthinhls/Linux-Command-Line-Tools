output "self_links" {
    value = flatten([
        google_compute_instance.bastion-machines.*.self_link,
        google_compute_instance.private-bastion-machines.*.self_link,
    ])
}
