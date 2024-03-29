# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Allow HTTP Daemon Scripts and Modules connect to the Network using TCP.
# @details: {@link https://cloud.google.com/load-balancing/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule/}
# @see {@link https://stackoverflow.com/questions/48253865/how-to-load-balance-google-compute-instance-using-terraform/}
# @see {@link https://binx.io/2018/11/19/how-to-configure-global-load-balancing-with-google-cloud-platform/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_http_health_check" "internal_load_balancers_health_checks" {
    name               = "internal-load-balancers-health-checks"
    request_path       = "/"
    port               = 8081
    check_interval_sec = 2
    timeout_sec        = 2
}

resource "google_compute_target_pool" "internal_load_balancers_target_pool" {
    name             = "internal-load-balancers-target-pool"
    region           = var.region
    session_affinity = "NONE"

    # instances = [google_compute_instance.load-balancers[0].self_link]
    instances = flatten([
        google_compute_instance.load-balancers.*.self_link,
        google_compute_instance.private-load-balancers.*.self_link,
    ])

    health_checks = [
        google_compute_http_health_check.internal_load_balancers_health_checks.name
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_forwarding_rule.external_network_load_balancers[0] external-network-load-balancers-01;
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "external_network_load_balancers" {
    count                 = 1 # Switch to [1] to provision again.
    depends_on            = [google_compute_address.load_balancers_ingress, google_compute_instance.load-balancers]
    name                  = "external-network-load-balancers-0${count.index + 1}"
    region                = var.region
    target                = google_compute_target_pool.internal_load_balancers_target_pool.self_link
    ip_address            = google_compute_address.load_balancers_ingress[count.index].address
    port_range            = "1-65535" // Default [null] assume all ports [1-65536]. Otherwise specify only one port::"80"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL"
}

output "network_load_balancers_ips" {
    value = google_compute_forwarding_rule.external_network_load_balancers.*.ip_address
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_address.keep_alived_instances[0] keep-alived-01;
# @command >> terraform state rm google_compute_address.keep_alived_instances[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_address.keep_alived_instances; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "load_balancers_ingress" {
    count           = var.load_balancers_ingress.reserved_external_ips # Switch to [1] to provision again.
    name            = "load-balancers-ingress-0${count.index + 1}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Load-Balancers-Ingress-0${count.index + 1}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

output "load_balancers_ingress" {
    value = google_compute_address.load_balancers_ingress.*.address
}
