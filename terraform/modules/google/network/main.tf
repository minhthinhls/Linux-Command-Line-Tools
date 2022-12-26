# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    root_domain = module.global.root_domain # Project Root Domain.
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Sub-Network CIDR (Classless Inter Domain Routing) IP Allocation.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    subnet_ip_cidr_range = {
        hongkong = {
            primary = coalesce(null, var.subnet_ip_cidr_range.hongkong.primary) # Migrate to ${var.subnet_ip_cidr_range.hongkong.primary}.
            secondary = coalesce(null, var.subnet_ip_cidr_range.hongkong.secondary, []) # Migrate to ${var.subnet_ip_cidr_range.hongkong.secondary}.
        }
        singapore = {
            primary = coalesce(null, var.subnet_ip_cidr_range.singapore.primary) # Migrate to ${var.subnet_ip_cidr_range.singapore.primary}.
            secondary = coalesce(null, var.subnet_ip_cidr_range.singapore.secondary, []) # Migrate to ${var.subnet_ip_cidr_range.singapore.secondary}.
        }
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network}.
# @see {@link https://cloud.google.com/sdk/gcloud/reference/compute/networks/delete}.
# @command >> gcloud compute networks subnets delete [main-network] ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_network" "this" {
    name                    = var.name
    auto_create_subnetworks = var.auto_create_subnetworks
    routing_mode            = var.routing_mode
    mtu                     = 0 # [1460]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Multiple Sub-Networks using Terraform. Each Sub-Network should have Multiple Secondary Addresses.
# @see {@link https://discuss.hashicorp.com/t/create-multiple-subnets-using-terraform-each-subnet-should-have-multiple-secondary-adresses/43671}.
# @see {@link https://stackoverflow.com/questions/72232623/ip-cidr-range-from-tf-vars-is-not-a-valid-ip-cidr-range-invalid-cidr-address}.
# @see {@link https://stackoverflow.com/questions/57890909/dynamic-block-with-for-each-inside-a-resource-created-with-a-for-each}.
# @see {@link https://stackoverflow.com/questions/58343258/iterate-over-nested-data-with-for-for-each-at-resource-level}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Manipulate Terraform Sub-Network Resources via Command Line Interfaces Application.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork}.
# @see {@link https://cloud.google.com/sdk/gcloud/reference/compute/networks/subnets/delete}.
# @command >> gcloud compute networks subnets delete [sub-network] --region=asia-east2 ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Refactoring / Transferring] State between Object Entries.
# @example:
# > terraform state mv \
# > module.network.google_compute_subnetwork.hongkong \
# > module.network.google_compute_subnetwork.this[\"hongkong\"] ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "this" {
    for_each = {
        for region in keys(local.subnet_ip_cidr_range)
        : region => local.subnet_ip_cidr_range[region]
    }
    name          = module.default.region_code[each.key] # Example: ["asia-east2"].
    ip_cidr_range = each.value["primary"] # Example: ["172.16.0.0/24"].
    region        = module.default.region_code[each.key] # Example: ["asia-east2"].
    network       = google_compute_network.this.id
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @warning: Existing ${secondary_ip_range} cannot be modified. Sub-network must be destroyed completely and then re-created as whole new resource.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Terraform will not update Dynamic Block ${secondary_ip_range} when [${secondary_ip_range.length} === 0].
    # @description: Attribute ${secondary_ip_range} must be set to empty array `[]`. This is a special case for this ${secondary_ip_range} field.
    # @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5801#issuecomment-594942222}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    dynamic secondary_ip_range {
        for_each = {for index, ip_cidr_range in each.value["secondary"] : (index + 2) => ip_cidr_range}
        content {
            range_name    = "${module.default.region_code[each.key]}-${secondary_ip_range.key}" # Example: ["asia-east2-2"].
            ip_cidr_range = secondary_ip_range.value # Example: ["192.168.0.0/24"].
        }
    }
    */
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @warning: Existing ${secondary_ip_range} cannot be modified. Sub-network must be destroyed completely and then re-created as whole new resource.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    secondary_ip_range  = [
        for index, ip_cidr_range in each.value["secondary"] : {
            range_name = "${module.default.region_code[each.key]}-${tonumber(index) + 2}" # Example: ["asia-east2-2"].
            ip_cidr_range = ip_cidr_range # Example: ["192.168.0.0/24"].
        }
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Apply Network Address Translation (NATs) to allow Private Instance connect to the Internet.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat/}.
# @see {@link https://stackoverflow.com/questions/47590302/google-cloud-vpc-internet-gateway/}.
# @see {@link https://cloud.google.com/nat/docs/overview/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
module "regional_router_nat" {
    source = "./modules/router-nat/region"
    network = google_compute_network.this
    subnetwork = google_compute_subnetwork.this["hongkong"]
}
