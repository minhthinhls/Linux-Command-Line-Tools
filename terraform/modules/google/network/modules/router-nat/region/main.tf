# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# @see {@link https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/}.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image/}.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Uppercase First Letter within Terraform String Format.
# @see {@link https://developer.hashicorp.com/terraform/language/functions/title/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    /* [[Optional Attributes Placeholder]] */
    lower_resource_id = "${lower(var.network.name)}-${lower(var.subnetwork.name)}" # Example: ["resource-unique-name"].
    camel_resource_id = "${title(var.network.name)}-${title(var.subnetwork.name)}" # Example: ["Resource-Unique-Name"].
    upper_resource_id = "${upper(var.network.name)}-${upper(var.subnetwork.name)}" # Example: ["RESOURCE-UNIQUE-NAME"].
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}.
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resources into Terraform Managed State.
# @command >> sudo terraform import google_compute_address.keep_alived_instances keep-alived-01 ;
# @see {@link https://stackoverflow.com/questions/70879211/importing-gcp-resource-into-terraform-fails-even-if-the-resource-exists/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "this" {
    count           = 1 # Switch to [1] to provision again.
    name            = "external-router-nat-${local.lower_resource_id}-${format("%02d", count.index + 1)}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Network-Address-Translation-${local.camel_resource_id}-${format("%02d", count.index + 1)}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    purpose         = null # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    # @description: [Regional / Zonal] Allocation.
    region          = var.subnetwork.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Apply Network Address Translation (NATs) to allow Private Instance connect to the Internet.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat/}.
# @see {@link https://stackoverflow.com/questions/47590302/google-cloud-vpc-internet-gateway/}.
# @see {@link https://cloud.google.com/nat/docs/overview/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_router" "this" {
    name    = "external-router-${var.network.name}-${var.subnetwork.name}"
    region  = var.subnetwork.region
    network = var.network.id
}

resource "google_compute_router_nat" "this" {
    name        = "external-router-nat-${var.network.name}-${var.subnetwork.name}"
    router      = google_compute_router.this.name
    region      = google_compute_router.this.region
    depends_on  = [google_compute_address.this]

    nat_ip_allocate_option = "MANUAL_ONLY"
    nat_ips                = google_compute_address.this.*.self_link

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name                    = var.subnetwork.id
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
}
