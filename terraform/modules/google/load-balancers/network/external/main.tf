# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    name    = var.general_options.name
    index   = var.index + 0
    suffix  = format("%02d", local.index)
    region  = coalesce(var.region, module.default.region) # Fallback to default ${global.region} when ${var.region} got omitted.
    zone    = coalesce(var.zone, module.default.zone) # Fallback to default ${global.zone} when ${var.zone} got omitted.
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    resource_id = "${lower(local.name)}-${local.suffix}" # Example: ["external-network-load-balancer-01"].
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
resource "google_compute_http_health_check" "this" {
    name               = local.resource_id
    request_path       = var.health_checks.path
    port               = var.health_checks.port
    check_interval_sec = 2 # [seconds]
    timeout_sec        = 2 # [seconds]
}

resource "google_compute_target_pool" "this" {
    count            = (var.provision_mode == "INITIALIZE") ? 1 : 0 # Switch to [1] to provision again.
    name             = local.resource_id
    region           = local.region
    instances        = flatten([var.endpoints])
    depends_on       = [google_compute_http_health_check.this]
    session_affinity = var.session_affinity # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"]

    health_checks = [
        google_compute_http_health_check.this.name
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_address.keep_alived_instances[0] keep-alived-01;
# @command >> terraform state rm google_compute_address.keep_alived_instances[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_address.keep_alived_instances; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "this" {
    name            = local.resource_id
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Network-Load-Balancer-${local.suffix}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    purpose         = null # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    # @description: [Regional / Zonal] Allocation.
    region          = local.region
    # zone          = local.zone # @argument named "zone" is not expected here.
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_forwarding_rule.external_network_load_balancers[0] external-network-load-balancers-01;
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule#import}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "this" {
    count                 = (var.provision_mode == "INITIALIZE") ? 1 : 0 # Switch to [1] to provision again.
    region                = local.region
    depends_on            = [google_compute_target_pool.this, google_compute_address.this]
    name                  = local.resource_id
    target                = google_compute_target_pool.this[0].self_link
    ip_address            = google_compute_address.this.address
    port_range            = "1-65535" // Default [null] assume all ports [1-65536]. Otherwise specify only one port::"80"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL"
}
