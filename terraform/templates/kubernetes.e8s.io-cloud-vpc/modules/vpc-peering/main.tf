terraform {
    required_version = ">= 0.12"
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
