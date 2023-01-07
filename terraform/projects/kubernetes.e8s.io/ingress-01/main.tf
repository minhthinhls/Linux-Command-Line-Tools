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
        name = "Load-Balancer" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags = "load-balancers" # ["bastion-machines", "load-balancers", "masters", "workers"].
    }
    network_options = {
        subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        public = false
    }
    subnet_ip_cidr_range = {
        hongkong = {
            primary = "172.16.0.0/24" # [Primary] Private Subnet IP Range.
            secondary = ["192.168.0.0/24"] # [Secondary] Private Subnet IP Range.
        }
        singapore = {
            primary = "172.18.0.0/24" # [Primary] Private Subnet IP Range.
            secondary = ["10.18.0.0/24"] # [Secondary] Private Subnet IP Range.
        }
    }
    gce_options = {
        machine_type = module.default.machine_type.e2["2-cpu-16gb-memory"]
        provisioning_model = "SPOT" # ["STANDARD", "SPOT"].
    }
    disk_options = {
        size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = null # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-load-balancers" # ["snapshot-<tags>"] - Snapshot Resources for Provisioning Boot Disks.
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

module "_secrets" {
    source = "../../../modules/google/secrets"
}

module "bastion-machines" {
    source = "../../../modules/google/bastion-machines"
    network = module.network
    secrets = module._secrets
    subnet_range = local.subnet_ip_cidr_range.hongkong.primary
    gce_options = {
        machine_type = module.default.machine_type.e2["1-cpu-1gb-memory"]
    }
    disk_options = {
        size = 20 # Gigabytes [32 GBs].
        type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
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
    secrets = module._secrets
    subnet_range = local.subnet_ip_cidr_range.hongkong.primary
    gce_options = {
        machine_type = "e2-standard-4" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
        type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
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

/*
module "load-balancers" {
    source = "../../../modules/google/load-balancers"
    network = module.network
    secrets = module._secrets
    subnet_range = local.subnet_ip_cidr_range.hongkong.primary
    gce_options = {
        machine_type = "e2-highmem-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
    }
    disk_options = {
        size = 64 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (20 GB)].
        type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = null # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-load-balancers" # Snapshot Resources for Provisioning Boot Disks.
    }
    reserved_external_ips = var.load_balancer_instances.reserved_external_ips
    reserved_boot_disks = var.load_balancer_instances.reserved_boot_disks
    offset_instances = var.load_balancer_instances.offset_instances
    number_instances = var.load_balancer_instances.number_instances
}
*/

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Refactoring / Transferring] State between Object Entries.
# @example:
# > terraform state mv \
# > module.masters.module.nodes[\"load-balancer-01\"].google_compute_instance.public_spot_vm[0] \
# > module.masters.module.nodes[\"load-balancer-01\"].google_compute_instance.private_spot_vm[0] ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
module "load-balancers" {
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
            machine_type = module.default.machine_type.e2["1-cpu-1gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"].
            # @description: Cannot specify both source image and source snapshot.
            image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"].
            # @description: Cannot specify both source image and source snapshot.
            snapshot = null # ["snapshot-<tags>"] - Snapshot Resources for Provisioning Boot Disks.
        }),
        snapshot_options = {
            name = "snapshot-load-balancers"
            enable = false
        }
        skip = true
        index = 0,
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
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        index = 1,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "b"]) # Example: ["asia-east2-b"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        index = 2,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "c"]) # Example: ["asia-east2-c"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        index = 3,
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
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        skip = true
        index = 4,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "b"]) # Example: ["asia-east2-b"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        skip = true
        index = 5,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
            zone = join("-", [local.availability_options.region, "c"]) # Example: ["asia-east2-c"].
        }),
        general_options = local.general_options,
        network_options = merge(local.network_options, {
            subnet_range = local.subnet_ip_cidr_range.hongkong.primary # Override $[`module.*.subnet_range`].
        }),
        gce_options = merge(local.gce_options, {
            machine_type = module.default.machine_type.e2["1-cpu-2gb-memory"]
            # provisioning_model = "X" # Terminate VM Instance.
        }),
        disk_options = merge(local.disk_options, {
            size = 20 # Gigabytes - [Requested disk size cannot be smaller than the snapshot size (250 GB)].
            type = "pd-balanced" # ["pd-standard", "pd-balanced", "pd-ssd"].
        }),
        skip = true
        index = 6,
    }]
}

module "external-network-load-balancers" {
    source = "../../../modules/google/load-balancers/network/external"
    #count = length(module.load-balancers.self_links) > 0 ? 1 : 0
    provision_mode = "INITIALIZE" # ["INITIALIZE", "TERMINATED"].
    session_affinity = "CLIENT_IP" # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"].
    depends_on = [module.load-balancers]
    endpoints = module.load-balancers.self_links
    index = 1
    config_pools = [{
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
        }),
        network_options = merge({
            strategy = "L4" # Example: ["L3", "L4"].
            protocol = "TCP" # Example: ["TCP", "UDP"]. Valid only for `Layer4` strategy.
            port_range = "1-65535", # Example: ["30000-32768"]. Valid only for `Layer4` strategy.
        }),
        provision_options = merge({
            mode = "FORWARDING_RULE_ENABLED" # ["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"].
        }),
        skip = false
        index = 1,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
        }),
        network_options = merge({
            strategy = "L4" # Example: ["L3", "L4"].
            protocol = "TCP" # Example: ["TCP", "UDP"]. Valid only for `Layer4` strategy.
            port_range = "80-443", # Example: ["30000-32768"]. Valid only for `Layer4` strategy.
        }),
        provision_options = merge({
            mode = "FORWARDING_RULE_ENABLED" # ["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"].
        }),
        skip = false
        index = 2,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
        }),
        network_options = merge({
            strategy = "L4" # Example: ["L3", "L4"].
            protocol = "TCP" # Example: ["TCP", "UDP"]. Valid only for `Layer4` strategy.
            port_range = "30000-32768", # Example: ["30000-32768"]. Valid only for `Layer4` strategy.
        }),
        provision_options = merge({
            mode = "FORWARDING_RULE_ENABLED" # ["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"].
        }),
        skip = false
        index = 4,
    }, {
        # @override - [${module.region} | ${module.zone}].
        availability_options = merge(local.availability_options, {
            region = local.availability_options.region # Example: ["asia-east2"].
        }),
        network_options = merge({
            strategy = "L3" # Example: ["L3", "L4"].
        }),
        provision_options = merge({
            mode = "FORWARDING_RULE_ENABLED" # ["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"].
        }),
        skip = true
        index = 3,
    }]
}
