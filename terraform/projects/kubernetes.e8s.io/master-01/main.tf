# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    regional_options = {
        name = "hongkong" # Example: ["hongkong", "singapore"]
    }
    availability_options = {
        region = module.default.region_code[local.regional_options.name] # Example: ["asia-east2"]
        zone = "${module.default.region_code[local.regional_options.name]}-a" # Example: ["asia-east2-a"]
    }
    general_options = {
        name = "Master" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags = "masters" # ["bastion-machines", "load-balancers", "masters", "workers"].
    }
    network_options = {
        subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        public = false
    }
    subnet_ip_cidr_range = {
        hongkong = {
            primary = "172.16.1.0/24" # [Primary] Private Subnet IP Range.
            secondary = ["192.168.1.0/24"] # [Secondary] Private Subnet IP Range.
        }
        singapore = {
            primary = "172.18.1.0/24" # [Primary] Private Subnet IP Range.
            secondary = ["10.18.1.0/24"] # [Secondary] Private Subnet IP Range.
        }
    }
    gce_options = {
        machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]].
        provisioning_model = "SPOT" # ["STANDARD", "SPOT"].
    }
    disk_options = {
        size = 64 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"].
        # @description: Cannot specify both source image and source snapshot.
        image = null # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-masters" # ["snapshot-<tags>"] - Snapshot Resources for Provisioning Boot Disks.
    }
}

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
    subnet_ip_cidr_range = merge(local.subnet_ip_cidr_range, {
        hongkong = {
            primary = local.subnet_ip_cidr_range.hongkong.primary # [Primary] Private Subnet IP Range.
            secondary = local.subnet_ip_cidr_range.hongkong.secondary # [Secondary] Private Subnet IP Range.
        }
        singapore = {
            primary = local.subnet_ip_cidr_range.singapore.primary # [Primary] Private Subnet IP Range.
            secondary = local.subnet_ip_cidr_range.singapore.secondary # [Secondary] Private Subnet IP Range.
        }
    })
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

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Refactoring / Transferring] State between Object Entries.
# @example:
# > terraform state mv \
# > module.masters.module.nodes[\"master-01\"].google_compute_instance.public_spot_vm[0] \
# > module.masters.module.nodes[\"master-01\"].google_compute_instance.private_spot_vm[0] ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
module "masters" {
    source = "../../../modules/google/node-pools"
    network = module.network
    secrets = module.secrets
    subnet_range = local.subnet_ip_cidr_range.hongkong.primary
    offset = 0 # Currently not in used.
    region = null # By default will fallback to `${module.default.region}`.
    zone = null # By default will fallback to `${module.default.zone}`.
    node_pools = [{
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "a"]) # Example: ["asia-east2-a"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = "e2-highmem-4" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-4"] -> ["4CPUs :: 32GBs RAM"]]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 122 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        }),
        index = 1,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "a"]) # Example: ["asia-east2-a"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 64 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        }),
        index = 2,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "a"]) # Example: ["asia-east2-a"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 64 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        }),
        index = 3,
    }]
}
