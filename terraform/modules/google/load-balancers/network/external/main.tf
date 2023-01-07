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
# @description: Provision Daemon Scripts checking Endpoints connectivity through HTTP.
# @details: {@link https://cloud.google.com/load-balancing/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts/}.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule/}.
# @see {@link https://stackoverflow.com/questions/48253865/how-to-load-balance-google-compute-instance-using-terraform/}.
# @see {@link https://binx.io/2018/11/19/how-to-configure-global-load-balancing-with-google-cloud-platform/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: This Terraform Resource <google_compute_http_health_check> act as GCP Health Check Service Instance.
# @resource {@link https://console.cloud.google.com/compute/healthChecks?project=<project_name>}
# @examples {@link https://console.cloud.google.com/compute/healthChecks?project=kubernetes-e8s-io-v1-ingress-1}.
# @resource {@link https://console.cloud.google.com/compute/healthChecksDetail/httpHealthChecks/<http_health_check_name>?project=<project_name>}.
# @examples {@link https://console.cloud.google.com/compute/healthChecksDetail/httpHealthChecks/external-network-load-balancer-01?project=kubernetes-e8s-io-v1-ingress-1}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_http_health_check" "this" {
    name               = local.resource_id
    request_path       = var.health_checks.path
    port               = var.health_checks.port
    check_interval_sec = 2 # [seconds]
    timeout_sec        = 2 # [seconds]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: This Terraform Resource <google_compute_target_pool> act as GCP Load Balancing Service Instance.
# @resource {@link https://console.cloud.google.com/net-services/loadbalancing/details/network/<subnet_name>/<target_pool_name>?project=<project_name>}.
# @examples {@link https://console.cloud.google.com/net-services/loadbalancing/details/network/asia-east2/external-network-load-balancer-01?project=kubernetes-e8s-io-v1-ingress-1}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_target_pool" "this" {
    count            = (var.provision_mode == "INITIALIZE") ? 1 : 0 # Switch to [1] to provision again.
    name             = local.resource_id # Description: Google Cloud Load-Balancer Unique <Resource_Name>.
    region           = local.region
    instances        = flatten([var.endpoints])
    depends_on       = [google_compute_http_health_check.this]
    session_affinity = var.session_affinity # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"].

    health_checks = [
        google_compute_http_health_check.this.name
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_address.keep_alived_instances[0] keep-alived-01;
# @command >> terraform state rm google_compute_address.keep_alived_instances[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_address.keep_alived_instances; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#import}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "this" {
    /**
     ** @key: String - Example ["01", "02", ...];
     ** @val: Object - Example [List<ConfigObj>];
     **/
    for_each = {
        for config in var.config_pools : join("-", [
            # Push extra pre-fix arguments before ${index} post-fix name below.
            format("%02d", coalesce(config["index"], var.index) + var.offset),
        ]) => merge(config, {
            /* [[Optional Attributes Placeholder]] */
        })
        if alltrue([
            coalesce(config["skip"], false) == false, # By default will not skip this Resource Instance.
            contains(["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"], config["provision_options"]["mode"]), # Check within valid options.
        ])
    }
    name            = "${lower(local.name)}-${each.key}" # Example: ["external-network-load-balancer-01"].
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"].
    description     = "External-static-ipv4-for-Network-Load-Balancer-${each.key}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"].
    # @description: The field cannot be specified with external address.
    purpose         = null # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"].
    # @description: [Regional / Zonal] Allocation.
    region          = local.region
    # zone          = local.zone # @argument named "zone" is not expected here.
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Google Cloud Platform (GCP) Layer 3 Default Network Load Balancer only accept Back-end Service Reference as ${target}.
# @see {@link https://cloud.google.com/load-balancing/docs/network/networklb-backend-service#forwarding-rule-protocols}.
# @see {@link https://cloud.google.com/load-balancing/docs/network/networklb-backend-service#backend-service}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Import Google Cloud Resource Instances into Terraform State Manager.
# @command >> terraform import google_compute_forwarding_rule.external_network_load_balancers[0] external-network-load-balancers-01;
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers[0]; # Delete Indexed Instance.
# @command >> terraform state rm google_compute_forwarding_rule.external_network_load_balancers; # Delete All Instances.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule#import}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: This Terraform Resource <google_compute_forwarding_rule> act as GCP Load Balancing Front-end.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "this" {
    /**
     ** @key: String - Example ["01", "02", ...];
     ** @val: Object - Example [List<ConfigObj>];
     **/
    for_each = {
        for config in var.config_pools : join("-", [
            # Push extra pre-fix arguments before ${index} post-fix name below.
            format("%02d", coalesce(config["index"], var.index) + var.offset),
        ]) => merge(config, {
            /* [[Optional Attributes Placeholder]] */
        })
        if alltrue([
            coalesce(config["skip"], false) == false, # By default will not skip this Resource Instance.
            config["provision_options"]["mode"] == "FORWARDING_RULE_ENABLED",
        ])
    }
    region                = coalesce(each.value["availability_options"]["region"], var.region, module.default.region)
    # zone                = coalesce(each.value["availability_options"]["zone"], var.zone, module.default.zone)
    depends_on            = [google_compute_target_pool.this, google_compute_address.this]
    name                  = "${lower(local.name)}-${each.key}" # Example: ["external-network-load-balancer-01"].
    target                = google_compute_target_pool.this[0].self_link
    ip_address            = google_compute_address.this[each.key].address
    all_ports             = each.value["network_options"]["strategy"] == "L3" ? true : null
    port_range            = each.value["network_options"]["strategy"] == "L3" ? null : each.value["network_options"]["port_range"]
    ip_protocol           = each.value["network_options"]["strategy"] == "L3" ? "L3_DEFAULT" : each.value["network_options"]["protocol"]
    load_balancing_scheme = "EXTERNAL"
}

/*
resource "google_compute_address" "L3" {
    name            = "${lower(local.name)}-03"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"].
    description     = "External-static-ipv4-for-Network-Load-Balancer-03"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"].
    # @description: The field cannot be specified with external address.
    purpose         = null # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"].
    # @description: [Regional / Zonal] Allocation.
    region          = local.region
    # zone          = local.zone # @argument named "zone" is not expected here.
}

resource "google_compute_http_health_check" "L3" {
    name               = "${lower(local.name)}-03"
    request_path       = var.health_checks.path
    port               = var.health_checks.port
    check_interval_sec = 2 # [seconds]
    timeout_sec        = 2 # [seconds]
}

resource "google_compute_target_pool" "L3" {
    name             = "${lower(local.name)}-03"
    region           = local.region
    instances        = flatten([var.endpoints[0]])
    depends_on       = [google_compute_http_health_check.L3]
    session_affinity = "NONE" # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"].

    health_checks = [
        google_compute_http_health_check.L3.name
    ]
}

resource "google_compute_target_instance" "L3" {
    name     = "ingress-proxy"
    zone     = "asia-east2-a" # HongKong [Zone::A].
    project  = "kubernetes-e8s-io-v1-ingress-1"
    # instance = module.load-balancers.self_links[1]
    instance = "https://www.googleapis.com/compute/v1/projects/kubernetes-e8s-io-v1-ingress-1/zones/asia-east2-a/instances/load-balancer-01"
}

resource "google_compute_forwarding_rule" "L3" {
    region                = local.region
    # zone                = coalesce(each.value["availability_options"]["zone"], var.zone, module.default.zone)
    depends_on            = [google_compute_target_pool.L3, google_compute_target_instance.L3, google_compute_address.L3]
    name                  = "${lower(local.name)}-03"
    target                = google_compute_target_instance.L3.self_link
    ip_address            = google_compute_address.L3.address
    all_ports             = true
    ip_protocol           = "L3_DEFAULT"
    load_balancing_scheme = "EXTERNAL"
}
*/
