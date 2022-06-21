# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Firewall within specific Region.
# @see {@link https://stackoverflow.com/questions/62231372/allow-ssh-access-to-gcp-vm-instances-provisioned-with-terraform#62245455}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "ssh-rule" {
    name    = "cluster-ssh"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["22"]
    }
    target_tags   = ["load-balancers", "masters", "workers"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ingress-rule" {
    name = "ingress-controllers"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["80", "443", "6443", "8080-8081", "8443"]
    }
    target_tags   = ["load-balancers"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kubernetes-shared-ports" {
    name    = "kubernetes-shared-ports"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["8090", "10250", "10255"]
    }
    allow {
        protocol = "udp"
        ports    = ["8285", "8472"] # Flannel Ports
    }
    target_tags   = ["masters", "workers"]
    source_ranges = ["172.16.0.0/22"]
}

resource "google_compute_firewall" "kubernetes-master-ports" {
    name    = "kubernetes-master-ports"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["2379-2380", "6443", "10251", "10252"]
    }
    target_tags   = ["masters"]
    source_ranges = ["172.16.0.0/22"]
}

resource "google_compute_firewall" "kubernetes-worker-ports" {
    name    = "kubernetes-worker-ports"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["30000-32767"]
    }
    target_tags   = ["workers"]
    source_ranges = ["172.16.0.0/22"]
}

resource "google_compute_firewall" "kubernetes-egress-ports" {
    name    = "kubernetes-egress-ports"
    network = google_compute_network.main_network.name
    allow {
        protocol = "tcp"
        ports    = ["0-65535"]
    }
    direction     = "EGRESS" # ["INGRESS", "EGRESS"]
    target_tags   = ["masters", "workers"]
    source_ranges = ["0.0.0.0/0"]
}
