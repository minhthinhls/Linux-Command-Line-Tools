# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = file(module.secrets.service_account["file_path"])
    project = module.secrets.service_account["project_id"]
}

module "network" {
    source = "../../../modules/google/network"
    region = "asia-east2" # HongKong
    # region = "asia-southeast1" # Singapore
    subnet_ips = [
        "172.16.1.0/24", # [Primary] Private IP Range.
        "192.168.1.0/24", # [Secondary] Private IP Range.
    ]
}

module "firewall" {
    source = "../../../modules/google/firewall"
    network = module.network.global_vpc
    depends_on = [
        module.network,
    ]
}

module "secrets" {
    source = "../../../modules/google/secrets"
}

module "snapshot-masters" {
    source = "../../../modules/google/snapshot-masters"
    network = module.network
    secrets = module.secrets
    subnet_range = "172.16.1.0/24"
    disk_options = {
        size = 20, # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        type = "pd-ssd", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = null # ["snapshot-masters"] - Snapshot Resources for Provisioning Boot Disks.
    }
    snapshot_options = {
        name = "snapshot-masters"
    }
    reserved_external_ips = var.snapshot_master_instances.reserved_external_ips
    reserved_boot_disks = var.snapshot_master_instances.reserved_boot_disks
    snapshots_instances = var.snapshot_master_instances.snapshots_instances
    offset_instances = var.snapshot_master_instances.offset_instances
    number_instances = var.snapshot_master_instances.number_instances
}

module "masters" {
    source = "../../../modules/google/masters"
    network = module.network
    secrets = module.secrets
    subnet_range = "172.16.1.0/24"
    gce_options = {
        machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 62, # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (20 GB)].
        type = "pd-ssd", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = null # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-masters", # Snapshot Resources for Provisioning Boot Disks.
    }
    reserved_external_ips = var.master_instances.reserved_external_ips
    reserved_boot_disks = var.master_instances.reserved_boot_disks
    offset_instances = var.master_instances.offset_instances
    number_instances = var.master_instances.number_instances
}
