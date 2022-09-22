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

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network}
# @see {@link https://cloud.google.com/sdk/gcloud/reference/compute/networks/delete}
# @command >> gcloud compute networks subnets delete [main-network]
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_network" "global_vpc" {
    name                    = "global-vpc"
    auto_create_subnetworks = "false"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork}
# @see {@link https://cloud.google.com/sdk/gcloud/reference/compute/networks/subnets/delete}
# @command >> gcloud compute networks subnets delete [sub-network] --region=asia-east2
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "hongkong" {
    name          = "asia-east2"
    ip_cidr_range = var.subnet_ips[0] # "172.16.0.0/24"
    region        = var.region
    network       = google_compute_network.global_vpc.id
    secondary_ip_range {
        range_name    = "asia-east2-2"
        ip_cidr_range = var.subnet_ips[1] # "192.168.0.0/24"
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Apply Network Address Translation (NATs) to allow Private Instance connect to the Internet.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat/}
# @see {@link https://stackoverflow.com/questions/47590302/google-cloud-vpc-internet-gateway/}
# @see {@link https://cloud.google.com/nat/docs/overview/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_router" "network_router" {
    name    = "kubernetes-egress-router"
    region  = google_compute_subnetwork.hongkong.region
    network = google_compute_network.global_vpc.id
}

resource "google_compute_router_nat" "network_router_nat" {
    name        = "kubernetes-egress-router-nat"
    router      = google_compute_router.network_router.name
    region      = google_compute_router.network_router.region
    depends_on  = [google_compute_address.external_network_address_translation_instances]

    nat_ip_allocate_option = "MANUAL_ONLY"
    nat_ips                = google_compute_address.external_network_address_translation_instances.*.self_link

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name                    = google_compute_subnetwork.hongkong.id
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
}
