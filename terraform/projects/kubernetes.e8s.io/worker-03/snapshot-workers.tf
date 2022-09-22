# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "snapshot-workers" {
    count           = var.snapshot_worker_instances.reserved_external_ips # Switch to [1] to provision again.
    name            = "snapshot-workers-0${count.index}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Snapshot-Workers-0${count.index}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "snapshot-workers" {
    count       = var.snapshot_worker_instances.reserved_boot_disks # Switch to [1] to provision again.
    name        = "ssd-worker-0${count.index}"
    type        = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
    zone        = "asia-east2-a" # "${var.zone}"
    # @description: Cannot specify both source image and source snapshot.
    image       = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
    # snapshot  = "snapshot-workers"
    labels      = tomap({role = "workers"})
    size        = 20 # Gigabytes
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk Snapshot from Persistent Disk.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_snapshot/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Delete Google Cloud Compute Instance Disk Snapshot from Terraform State.
# @command >> terraform state rm google_compute_snapshot.workers;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_snapshot" "workers" {
    count       = var.snapshot_worker_instances.snapshots_instances # Switch to [1] to provision again.
    name        = "snapshot-workers"
    zone        = "asia-east2-a" # "${var.zone}"
    source_disk = google_compute_disk.snapshot-workers[count.index].id
    description = "Snap shot SSD for Worker Nodes."
    labels = {
        role = "worker"
    }
    storage_locations = [var.region]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "snapshot-workers" {
    count        = var.snapshot_worker_instances.number_instances # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "worker-0${count.index}"
    hostname     = "worker-0${count.index}.e8s.io"
    machine_type = "e2-standard-8" # [["e2-standard-4"], ["e2-standard-8"]] -> [["4CPUs :: 16GBs RAM"], ["8CPUs :: 32GBs RAM"]]
    tags         = ["workers"]

    metadata = {
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "SSD-Worker-0${count.index}"
        source = google_compute_disk.snapshot-workers[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = google_compute_network.global_vpc.self_link
        subnetwork  = google_compute_subnetwork.hongkong.self_link
        network_ip  = "172.16.4.${(100 + count.index)}"
        access_config {
            nat_ip = try(google_compute_address.snapshot-workers[count.index].address, "")
        }
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = local.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.load-balancers[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'worker-0${count.index}.e8s.io';",
            "echo 'worker-0${count.index}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
