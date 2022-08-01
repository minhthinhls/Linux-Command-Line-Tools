# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "masters" {
    count           = var.master_instances.reserved_external_ips # Switch to [1] to provision again.
    name            = "master-0${count.index + 1}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Master-0${count.index + 1}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "masters" {
    count       = var.master_instances.reserved_boot_disks # Switch to [1] to provision again.
    name        = "ssd-master-0${count.index + 1}"
    type        = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
    zone        = "asia-east2-a" # "${var.zone}"
    snapshot    = "snapshot-masters"
    labels      = tomap({role = "masters"})
    size        = 20 # Gigabytes
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "masters" {
    count        = ((var.master_instances.number_instances > var.master_instances.reserved_external_ips) ?
                    (var.master_instances.reserved_external_ips) :
                    (var.master_instances.number_instances)) # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "master-0${count.index + 1}"
    hostname     = "master-0${count.index + 1}.e8s.io"
    machine_type = "e2-custom-2-3072" # [["e2-small"], ["e2-custom-2-3072"]] -> [["2CPUs :: 2GBs RAM"], ["2CPUs :: 3GBs RAM"]]
    tags         = ["masters"]

    metadata = {
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'master-0${count.index + 1}.e8s.io';
            echo 'master-0${count.index + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "SSD-Master-0${count.index + 1}"
        source = google_compute_disk.masters[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = google_compute_network.main_network.self_link
        subnetwork  = google_compute_subnetwork.sub_network.self_link
        network_ip  = "172.16.1.${count.index + 1}"
        access_config {
            nat_ip = try(google_compute_address.masters[count.index].address, "")
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
            # @deprecated: {{ host = google_compute_address.masters[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'master-0${count.index + 1}.e8s.io';",
            "echo 'master-0${count.index + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "private-masters" {
    count        = ((var.master_instances.number_instances > var.master_instances.reserved_external_ips) ?
                    (var.master_instances.number_instances - var.master_instances.reserved_external_ips) :
                    (0)) # Switch to [1] to provision again.
    depends_on   = [google_compute_instance.load-balancers]
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = "master-0${count.index + var.master_instances.reserved_external_ips + 1}"
    hostname     = "master-0${count.index + var.master_instances.reserved_external_ips + 1}.e8s.io"
    machine_type = "e2-custom-2-3072" # [["e2-small"], ["e2-custom-2-3072"]] -> [["2CPUs :: 2GBs RAM"], ["2CPUs :: 3GBs RAM"]]
    tags         = ["masters"]

    metadata = {
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'master-0${count.index + var.master_instances.reserved_external_ips + 1}.e8s.io';
            echo 'master-0${count.index + var.master_instances.reserved_external_ips + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "SSD-Master-0${count.index + var.master_instances.reserved_external_ips + 1}"
        source = google_compute_disk.masters[count.index + var.master_instances.reserved_external_ips].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = google_compute_network.main_network.self_link
        subnetwork  = google_compute_subnetwork.sub_network.self_link
        network_ip  = "172.16.1.${count.index + var.master_instances.reserved_external_ips + 1}"
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
            # @deprecated: {{ host = google_compute_address.masters[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].network_ip
            type        = "ssh"
            user        = var.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.gce_ssh_private_key_file)

            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: SSH Through Kubernetes Cluster Bastion Machine.
            # @see {@link https://github.com/hashicorp/terraform/issues/18889/}
            # @see {@link https://www.terraform.io/language/resources/provisioners/connection#connecting-through-a-bastion-host-with-ssh/}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            bastion_host        = "bastion-ingress.e8s.io"
            bastion_port        = 22
            bastion_user        = "admin.e8s.io"
            bastion_private_key = file(var.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'master-0${count.index + var.master_instances.reserved_external_ips + 1}.e8s.io';",
            "echo 'master-0${count.index + var.master_instances.reserved_external_ips + 1}.e8s.io' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
