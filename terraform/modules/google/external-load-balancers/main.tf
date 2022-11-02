# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    name = var.general_options.name
    index = var.index + 0
    suffix = format("%02d", local.index)
    resource_id = "${lower(local.name)}-${local.suffix}"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Allow HTTP Daemon Scripts and Modules connect to the Network using TCP.
# @details: {@link https://cloud.google.com/load-balancing/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule/}
# @see {@link https://stackoverflow.com/questions/48253865/how-to-load-balance-google-compute-instance-using-terraform/}
# @see {@link https://binx.io/2018/11/19/how-to-configure-global-load-balancing-with-google-cloud-platform/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_http_health_check" "external_network_load_balancer" {
    name               = "external-network-load-balancer-${local.suffix}"
    request_path       = var.health_checks.path
    port               = var.health_checks.port
    check_interval_sec = 2 # [seconds]
    timeout_sec        = 2 # [seconds]
}

resource "google_compute_target_pool" "external_network_load_balancer" {
    count            = (var.provision_mode == "INITIALIZE") ? 1 : 0 # Switch to [1] to provision again.
    name             = "external-network-load-balancer-${local.suffix}"
    region           = var.region
    instances        = flatten([var.endpoints])
    depends_on       = [google_compute_http_health_check.external_network_load_balancer]
    session_affinity = var.session_affinity # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"]

    health_checks = [
        google_compute_http_health_check.external_network_load_balancer.name
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_address.keep_alived_instances[0] keep-alived-01;
# @command >> terraform state rm google_compute_address.keep_alived_instances[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_address.keep_alived_instances; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "external_network_load_balancer" {
    name            = "external-network-load-balancer-${local.suffix}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Network-Load-Balancer-${local.suffix}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_forwarding_rule.external_network_load_balancers[0] external-network-load-balancers-01;
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "external_network_load_balancer" {
    count                 = (var.provision_mode == "INITIALIZE") ? 1 : 0 # Switch to [1] to provision again.
    region                = var.region
    depends_on            = [google_compute_target_pool.external_network_load_balancer, google_compute_address.external_network_load_balancer]
    name                  = "external-network-load-balancer-${local.suffix}"
    target                = google_compute_target_pool.external_network_load_balancer[0].self_link
    ip_address            = google_compute_address.external_network_load_balancer.address
    port_range            = "1-65535" // Default [null] assume all ports [1-65536]. Otherwise specify only one port::"80"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL"
}
