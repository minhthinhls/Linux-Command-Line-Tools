# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://cloud.google.com/architecture/patterns-for-floating-ip-addresses-in-compute-engine/}
# @see {@link https://github1s.com/GoogleCloudPlatform/solutions-floating-ip-patterns-terraform/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_route" "kubernetes_external_network_router_01" {
    name            = "kubernetes-external-network-router-01"
    network         = google_compute_network.main_network.name
    depends_on      = [google_compute_subnetwork.sub_network]
    # dest_range      = "${google_compute_address.keep_alived_instances[0].address}/32"
    dest_range      = "35.241.76.231/32"
    next_hop_instance = google_compute_instance.load-balancers[0].name
    next_hop_instance_zone = google_compute_instance.load-balancers[0].zone
    # next_hop_ip     = "172.16.0.2"
    priority        = 100
}

/*
resource "google_compute_route" "kubernetes_external_network_router_02" {
    name            = "kubernetes-external-network-router-02"
    network         = google_compute_network.main_network.name
    depends_on      = [google_compute_subnetwork.sub_network]
    dest_range      = "${google_compute_address.keep_alived_instances[0].address}/32"
    next_hop_ip     = "172.16.0.2"
    priority        = 100
}

resource "google_compute_firewall" "failover_firewall_ssh_iap" {
    name = "failover-ssh-iap"
    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    network = google_compute_network.main_network.id
    #IP range used by Identity-Aware-Proxy
    #See https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
    source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "failover_firewall_hc" {
    name = "failover-hc"
    allow {
        protocol = "tcp"
        ports    = ["80"]
    }
    network = google_compute_network.main_network.id
    #IP ranges used for health checks
    #See https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
    source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
*/
