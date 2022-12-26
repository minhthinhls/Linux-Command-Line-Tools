# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: The following `${this}` property refer to the VPC Main-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "this" {
    value = google_compute_network.this
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: This `${main_network}` property refer to the VPC Main-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "main_network" {
    value = google_compute_network.this
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: This `${global_vpc}` property refer to the VPC Main-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "global_vpc" {
    value = google_compute_network.this
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: This `${sub_network}` property refer to the VPC Sub-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "sub_network" {
    value = google_compute_subnetwork.this
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: This `${subnet}` property refer to the VPC Sub-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "subnet" {
    value = google_compute_subnetwork.this
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @alias: This `${hongkong}` property refer to the VPC `asia-east2` Sub-Network Resource as Google Cloud Platform (GCP) specified Terraform Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
output "hongkong" {
    value = google_compute_subnetwork.this["hongkong"]
}

output "external_router_nat" {
    value = module.regional_router_nat
}
