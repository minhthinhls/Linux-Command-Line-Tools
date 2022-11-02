# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Delete Google Cloud Compute Instance Disk Snapshot from Terraform State.
# @command >> terraform state rm module.snapshot-load-balancers.google_compute_snapshot.load-balancers ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "phase" {
    default = "PROVISION" # ["SUBSTITUTE", "SNAPSHOT", "PROVISION", "CLEAN", "TERMINATE"]
    description = <<EOF
        ["SUBSTITUTE"]: Initiate the [Original-Machine] to be installed with fundamental dependencies ;
        [ "SNAPSHOT" ]: Snapshot the [Original-Disk] installed with fundamental dependencies ;
        [_"PROVISION"]: Create the [Virtual-Machines] from [Disk-Snapshot] Resource ;
        [  _"CLEAN"  ]: Delete the [Original-Machine] && [Original-Disk] ;
        [_"TERMINATE"]: Remove the [Virtual-Machines] && [Virtual-Disks] ;
    EOF
}

variable "snapshot_master_instances" {
    default = {
        reserved_external_ips = 0 # 1
        reserved_boot_disks = 0 # 1
        snapshots_instances = 0 # 1
        offset_instances = 0
        number_instances = 0 # 1
    }
}
