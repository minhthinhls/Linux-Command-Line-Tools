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
    ip_cidr_range = "172.16.1.0/24"
    region        = var.region
    network       = google_compute_network.global_vpc.id
    secondary_ip_range {
        range_name    = "asia-east2-2"
        ip_cidr_range = "192.168.1.0/24"
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
