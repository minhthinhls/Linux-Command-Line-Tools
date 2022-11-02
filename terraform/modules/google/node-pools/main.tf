# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Node VMs Module will be an Object with Key assigned as Virtual Machine Identify Name.
# @see {@link https://stackoverflow.com/questions/65636463/terraform-using-for-each-in-module/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
module "nodes" {
    source = "../../../modules/google/compute-engine"
    for_each = {
        for node in var.node_pools : join("-", [
            lower(node["general_options"]["name"]),
            format("%02d", coalesce(node["index"], var.index) + var.offset),
        ]) => node
    }
    network = var.network
    secrets = var.secrets
    index = coalesce(each.value["index"], var.index) - 1 + var.offset
    general_options = {
        name = each.value["general_options"]["name"]
        tags = each.value["general_options"]["tags"]
        domain = coalesce(each.value["general_options"]["domain"], "e8s.io")
    }
    network_options = {
        subnet_range = coalesce(each.value["network_options"]["subnet_range"], var.subnet_range)
        public = coalesce(each.value["network_options"]["public"], true)
    }
    gce_options = {
        machine_type = coalesce(each.value["gce_options"]["machine_type"], "e2-small") # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
        provisioning_model = coalesce(each.value["gce_options"]["provisioning_model"], "STANDARD") # ["STANDARD", "SPOT"].
    }
    disk_options = {
        size = each.value["disk_options"]["size"] # Gigabytes
        type = each.value["disk_options"]["type"] # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = each.value["disk_options"]["image"] # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = each.value["disk_options"]["snapshot"] # ["snapshot-*"] Snapshot Resources for Provisioning Boot Disks.
    }
}
