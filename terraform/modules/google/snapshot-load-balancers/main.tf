# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    offset = var.offset_instances # Instance Indexing Offset.
    expose = var.reserved_external_ips # Instance Public Offset.
    subnet_range = split(".", var.subnet_range)
    subnet_prefix = join(".", slice(local.subnet_range, 0, length(local.subnet_range) - 1)) # Remove Last Segment. Ex: [172.16.0.0/24] -> [172.16.0]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "snapshot-load-balancers" {
    count           = var.reserved_external_ips # Switch to [1] to provision again.
    name            = "snapshot-load-balancer-${format("%02d", (count.index + local.offset) + 1)}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Snapshot-Load-Balancer-${format("%02d", (count.index + local.offset) + 1)}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "snapshot-load-balancers" {
    count       = var.reserved_boot_disks # Switch to [1] to provision again.
    name        = "${var.disk_options.type}-snapshot-load-balancer-${format("%02d", (count.index + local.offset) + 1)}"
    type        = var.disk_options.type # ["pd-standard", "pd-balanced", "pd-ssd"]
    zone        = var.zone
    # @description: Cannot specify both source image and source snapshot.
    image       = try(var.disk_options.image, "") # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
    # @description: Cannot specify both source image and source snapshot.
    snapshot    = try(var.disk_options.snapshot, "")
    labels      = tomap({role = "load-balancers"})
    size        = var.disk_options.size # Gigabytes
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk Snapshot from Persistent Disk.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_snapshot/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Delete Google Cloud Compute Instance Disk Snapshot from Terraform State.
# @command >> terraform state rm google_compute_snapshot.load-balancers;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_snapshot" "load-balancers" {
    count       = try(var.snapshots_instances, 0) # Switch to [1] to provision again.
    name        = var.snapshot_options.name
    zone        = var.zone
    labels      = tomap({role = "load-balancer"})
    source_disk = google_compute_disk.snapshot-load-balancers[count.index].id
    description = "Snapshot ${upper(var.disk_options.type)} for Load-Balancer Nodes."
    storage_locations = [var.region]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "snapshot-load-balancers" {
    count        = ((var.number_instances > var.reserved_external_ips) ?
                    (var.reserved_external_ips) :
                    (var.number_instances)) # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "load-balancer-${format("%02d", (count.index + local.offset) + 1)}"
    hostname     = "load-balancer-${format("%02d", (count.index + local.offset) + 1)}.e8s.io"
    machine_type = var.gce_options.machine_type # [["e2-standard-4"] -> ["4CPUs :: 16GBs RAM"]] && [["e2-standard-8"] -> ["8CPUs :: 32GBs RAM"]]
    zone         = var.zone
    tags         = ["load-balancers"]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'load-balancer-${format("%02d", (count.index + local.offset) + 1)}.e8s.io';
            echo 'load-balancer-${format("%02d", (count.index + local.offset) + 1)}.e8s.io' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-Load-Balancer-${format("%02d", (count.index + local.offset) + 1)}"
        source = google_compute_disk.snapshot-load-balancers[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${(200 + count.index + local.offset) + 1}"
        access_config {
            nat_ip = try(google_compute_address.snapshot-load-balancers[count.index].address, "")
        }
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling}
    scheduling {
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart}
        preemptible                 = true
        automatic_restart           = false
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
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
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'load-balancer-${format("%02d", (count.index + local.offset) + 1)}.e8s.io';",
            "echo 'load-balancer-${format("%02d", (count.index + local.offset) + 1)}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "private-snapshot-load-balancers" {
    count        = ((var.number_instances > var.reserved_external_ips) ?
                    (var.number_instances - var.reserved_external_ips) :
                    (0)) # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}"
    hostname     = "load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}.e8s.io"
    machine_type = var.gce_options.machine_type # [["e2-standard-4"] -> ["4CPUs :: 16GBs RAM"]] && [["e2-standard-8"] -> ["8CPUs :: 32GBs RAM"]]
    zone         = var.zone
    tags         = ["load-balancers"]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}.e8s.io';
            echo 'load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}.e8s.io' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-Load-Balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}"
        source = google_compute_disk.snapshot-load-balancers[count.index + local.expose].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${(200 + count.index + local.offset + local.expose) + 1}"
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling}
    scheduling {
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart}
        preemptible                 = true
        automatic_restart           = false
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.load-balancers[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].network_ip
            type        = "ssh"
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)

            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: SSH Through Kubernetes Cluster Bastion Machine.
            # @see {@link https://github.com/hashicorp/terraform/issues/18889/}
            # @see {@link https://www.terraform.io/language/resources/provisioners/connection#connecting-through-a-bastion-host-with-ssh/}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            bastion_host        = "bastion-ingress.e8s.io"
            bastion_port        = 22
            bastion_user        = var.secrets.gce_ssh_user
            bastion_private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}.e8s.io';",
            "echo 'load-balancer-${format("%02d", (count.index + local.offset + local.expose) + 1)}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
