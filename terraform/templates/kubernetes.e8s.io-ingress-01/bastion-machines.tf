# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    bastion_machines = {
        offset = var.bastion_machine_instances.offset_instances # Instance Indexing Offset.
        expose = var.bastion_machine_instances.reserved_external_ips # Instance Public Offset.
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "bastion-machines" {
    count           = var.bastion_machine_instances.reserved_external_ips # Switch to [1] to provision again.
    name            = "bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Bastion-Machine-0${(count.index + local.bastion_machines.offset) + 1}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "bastion-machines" {
    count       = var.bastion_machine_instances.reserved_boot_disks # Switch to [1] to provision again.
    name        = "ssd-bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}"
    type        = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
    zone        = "asia-east2-a" # "${var.zone}"
    # @description: Cannot specify both source image and source snapshot.
    image       = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
    # snapshot  = "snapshot-bastion-machines"
    labels      = tomap({role = "bastion-machines"})
    size        = 20 # Gigabytes
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "bastion-machines" {
    count        = var.bastion_machine_instances.number_instances # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}"
    hostname     = "bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}.e8s.io"
    machine_type = "e2-small" # [["e2-small"], ["e2-highmem-2"]] -> [["2CPUs :: 2GBs RAM"], ["2CPUs :: 16GBs RAM"]]
    tags         = ["bastion-machines"]

    metadata = {
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}.e8s.io';
            echo 'bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "SSD-Bastion-Machine-0${(count.index + local.bastion_machines.offset) + 1}"
        source = google_compute_disk.bastion-machines[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = google_compute_network.global_vpc.self_link
        subnetwork  = google_compute_subnetwork.hongkong.self_link
        network_ip  = "172.16.0.${(200 + count.index + local.bastion_machines.offset) + 1}" # Avoid Gateway: [172.16.0.1]
        access_config {
            nat_ip = try(google_compute_address.bastion-machines[count.index].address, "")
        }
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = local.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling}
    scheduling {
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart}
        preemptible                 = false # [Default: "false"]
        automatic_restart           = true # [Default: "true"]
        on_host_maintenance         = "MIGRATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "STANDARD" # ["STANDARD", "SPOT"]
        # instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.bastion-machines[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}.e8s.io';",
            "echo 'bastion-machine-0${(count.index + local.bastion_machines.offset) + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
