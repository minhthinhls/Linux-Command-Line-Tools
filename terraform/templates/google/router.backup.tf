/*
# @see {@link https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route}
resource "google_compute_route" "kubernetes_nodes_router" {
    name                = "kubernetes-nodes-router"
    network             = google_compute_network.main_network.name
    dest_range          = "0.0.0.0/0"
    # @description: This value will be decided automatically based on the result of applying this configuration.
    # next_hop_network  = google_compute_network.main_network.self_link
    # dest_range        = google_compute_subnetwork.sub_network.secondary_ip_range[0].ip_cidr_range
    next_hop_ilb        = google_compute_forwarding_rule.kubernetes-cluster.id
    priority            = 100
}

resource "google_compute_health_check" "health-checker" {
    name               = "proxy-health-check"
    check_interval_sec = 1
    timeout_sec        = 1

    tcp_health_check {
        port = "80"
    }
}

resource "google_compute_region_backend_service" "kubernetes-cluster" {
    name          = "kubernetes-cluster"
    region        = var.region
    health_checks = [google_compute_health_check.health-checker.id]
}

resource "google_compute_forwarding_rule" "kubernetes-cluster" {
    name                    = "kubernetes-cluster-forwarding-rule"
    region                  = var.region

    load_balancing_scheme   = "INTERNAL"
    backend_service         = google_compute_region_backend_service.kubernetes-cluster.id
    subnetwork              = google_compute_subnetwork.sub_network.name
    network                 = google_compute_network.main_network.name
    all_ports               = true
}
*/
