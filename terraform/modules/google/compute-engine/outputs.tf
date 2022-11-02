output "self_links" {
    value = flatten([
        google_compute_instance.public_standard_vm.*.self_link,
        google_compute_instance.private_standard_vm.*.self_link,
        google_compute_instance.public_spot_vm.*.self_link,
        google_compute_instance.private_spot_vm.*.self_link,
    ])
}
