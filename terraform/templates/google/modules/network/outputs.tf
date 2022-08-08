output "external_network_address_translation_instances" {
    value = google_compute_address.external_network_address_translation_instances.*.address
}

output "global_vpc" {
    value = google_compute_network.global_vpc
}

output "hongkong" {
    value = google_compute_subnetwork.hongkong
}
