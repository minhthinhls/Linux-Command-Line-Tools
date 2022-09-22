# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resources into Terraform Managed State.
# @command >> sudo terraform import google_compute_address.keep_alived_instances keep-alived-01;
# @see {@link https://stackoverflow.com/questions/70879211/importing-gcp-resource-into-terraform-fails-even-if-the-resource-exists/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "external_network_address_translation_instances" {
    count           = 1 # Switch to [1] to provision again.
    name            = "external-network-address-translation-0${count.index + 1}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Network-Address-Translation-0${count.index + 1}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

output "external_network_address_translation_instances" {
    value = google_compute_address.external_network_address_translation_instances.*.address
}
