# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform get Item Index from List Iteration.
# @deprecation: The module at module.vpc-peering is a legacy module which contains its own local provider configurations,
# │ and so calls to it may not use the count, for_each, or depends_on arguments.
# @deprecation: If you also control the module "*/modules/google/vpc-peering",
# │ consider updating this module to instead expect provider configurations to be passed by its caller.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://stackoverflow.com/questions/57512884/is-provider-variable-possible-in-terraform/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = var.gcp_provider.credential
    project     = var.gcp_provider.project_id
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform get Item Index from List Iteration.
# @see {@link https://stackoverflow.com/questions/61343796/terraform-get-list-index-on-for-each/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_network_peering" "bootstrap" {
    for_each     = var.others
    name         = "peering-${each.value}" # Get item index.
    network      = "https://www.googleapis.com/compute/v1/projects/${var.current}/global/networks/global-vpc"
    peer_network = "https://www.googleapis.com/compute/v1/projects/${each.value}/global/networks/global-vpc"
}
