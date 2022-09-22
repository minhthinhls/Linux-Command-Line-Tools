output "google_compute_firewall" {
    value = tomap({
        ssh-rule: google_compute_firewall.ssh-rule,
        ingress-rule: google_compute_firewall.ingress-rule,
        kubernetes-egress-ports: google_compute_firewall.kubernetes-egress-ports,
        kubernetes-shared-ports: google_compute_firewall.kubernetes-shared-ports,
        kubernetes-master-ports: google_compute_firewall.kubernetes-master-ports,
        kubernetes-worker-ports: google_compute_firewall.kubernetes-worker-ports,
    })
}
