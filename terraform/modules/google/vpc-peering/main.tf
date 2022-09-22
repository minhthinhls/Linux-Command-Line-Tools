# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform get Item Index from List Iteration.
# @see {@link https://stackoverflow.com/questions/57512884/is-provider-variable-possible-in-terraform/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = var.gcp_provider.credential
    project = var.gcp_provider.project_id
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform get Item Index from List Iteration.
# @see {@link https://stackoverflow.com/questions/61343796/terraform-get-list-index-on-for-each/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_network_peering" "bootstrap" {
    for_each     = var.others
    name         = "peering-${index(tolist(var.others), each.value) + 1}" # Get item index.
    network      = var.current
    peer_network = each.value
}
