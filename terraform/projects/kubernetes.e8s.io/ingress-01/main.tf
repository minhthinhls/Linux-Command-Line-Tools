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
        "172.16.0.0/24", # [Primary] Private IP Range.
        "192.168.0.0/24", # [Secondary] Private IP Range.
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

module "bastion-machines" {
    source = "../../../modules/google/bastion-machines"
    network = module.network
    secrets = module.secrets
    subnet_range = "172.16.0.0/24"
    gce_options = {
        machine_type = "e2-small" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 32, # Gigabytes
        type = "pd-ssd", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = null # ["snapshot-load-balancers"] - Snapshot Resources for Provisioning Boot Disks.
    }
    reserved_external_ips = var.bastion_machine_instances.reserved_external_ips
    reserved_boot_disks = var.bastion_machine_instances.reserved_boot_disks
    offset_instances = var.bastion_machine_instances.offset_instances
    number_instances = var.bastion_machine_instances.number_instances
}

module "snapshot-load-balancers" {
    source = "../../../modules/google/snapshot-load-balancers"
    network = module.network
    secrets = module.secrets
    subnet_range = "172.16.0.0/24"
    gce_options = {
        machine_type = "e2-standard-4" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 20, # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        type = "pd-ssd", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = null # ["snapshot-load-balancers"] - Snapshot Resources for Provisioning Boot Disks.
    }
    snapshot_options = {
        name = "snapshot-load-balancers"
    }
    reserved_external_ips = var.snapshot_load_balancer_instances.reserved_external_ips
    reserved_boot_disks = var.snapshot_load_balancer_instances.reserved_boot_disks
    snapshots_instances = var.snapshot_load_balancer_instances.snapshots_instances
    offset_instances = var.snapshot_load_balancer_instances.offset_instances
    number_instances = var.snapshot_load_balancer_instances.number_instances
}

module "load-balancers" {
    source = "../../../modules/google/load-balancers"
    network = module.network
    secrets = module.secrets
    subnet_range = "172.16.0.0/24"
    gce_options = {
        machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 64, # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (20 GB)].
        type = "pd-ssd", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = null # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-load-balancers", # Snapshot Resources for Provisioning Boot Disks.
    }
    reserved_external_ips = var.load_balancer_instances.reserved_external_ips
    reserved_boot_disks = var.load_balancer_instances.reserved_boot_disks
    offset_instances = var.load_balancer_instances.offset_instances
    number_instances = var.load_balancer_instances.number_instances
}

module "external-load-balancers" {
    source = "../../../modules/google/external-load-balancers"
    #count = length(module.load-balancers.self_links) > 0 ? 1 : 0
    provision_mode = "INITIALIZE" # ["INITIALIZE", "TERMINATED"].
    session_affinity = "CLIENT_IP" # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"].
    depends_on = [module.load-balancers]
    endpoints = module.load-balancers.self_links
    index = 1
}
