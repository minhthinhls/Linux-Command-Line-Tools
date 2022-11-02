# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Delete Google Cloud Compute Instance Disk Snapshot from Terraform State.
# @command >> terraform state rm module.snapshot-load-balancers.google_compute_snapshot.load-balancers ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "bastion_machine_instances" {
    default = {
        reserved_external_ips = 1 # 1
        reserved_boot_disks = 1 # 1
        offset_instances = 0 # 0
        number_instances = 1 # 1
    }
}

variable "snapshot_load_balancer_instances" {
    default = {
        reserved_external_ips = 0 # 1
        reserved_boot_disks = 0 # 1
        snapshots_instances = 0 # 1
        offset_instances = 0
        number_instances = 0 # 1
    }
}

variable "load_balancer_instances" {
    default = {
        reserved_external_ips = 0
        reserved_boot_disks = 3 # 3
        offset_instances = 0 # 0
        number_instances = 3 # 3
    }
}
