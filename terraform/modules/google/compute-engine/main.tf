# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    name = var.general_options.name
    tags = var.general_options.tags
    domain = var.general_options.domain
    gce_model = var.gce_options.provisioning_model # ["STANDARD", "SPOT"].
    index = var.index + 1
    suffix = format("%02d", local.index)
    resource_id = "${lower(local.name)}-${local.suffix}"
    subnet_range = split(".", var.network_options.subnet_range)
    subnet_prefix = join(".", slice(local.subnet_range, 0, length(local.subnet_range) - 1)) # Remove Last Segment. Ex: [172.16.0.0/24] -> [172.16.0]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address}
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "this" {
    count           = var.network_options.public ? 1 : 0
    name            = local.resource_id
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-${local.name}-${local.suffix}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    # purpose       = "GCE_ENDPOINT" # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    region          = var.region
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "this" {
    name        = "${var.disk_options.type}-${local.resource_id}"
    type        = var.disk_options.type # ["pd-standard", "pd-balanced", "pd-ssd"]
    zone        = var.zone
    # @description: Cannot specify both source image and source snapshot.
    image       = try(var.disk_options.image, "") # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
    # @description: Cannot specify both source image and source snapshot.
    snapshot    = try(var.disk_options.snapshot, "")
    labels      = tomap({role = local.tags})
    size        = var.disk_options.size # Gigabytes
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "public_standard_vm" {
    count        = (local.gce_model == "STANDARD" && var.network_options.public) ? 1 : 0 # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = local.resource_id
    hostname     = "${local.resource_id}.${local.domain}"
    machine_type = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    zone         = var.zone
    tags         = [local.tags]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';
            echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-${local.name}-${local.suffix}"
        source = google_compute_disk.this.name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${100 + local.index}"
        access_config {
            nat_ip = try(google_compute_address.this[0].address, "")
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
        preemptible         = false # [Default: "false"]
        automatic_restart   = true # [Default: "true"]
        on_host_maintenance = "MIGRATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model  = "STANDARD" # ["STANDARD", "SPOT"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.this[0].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';",
            "echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "private_standard_vm" {
    count        = (local.gce_model == "STANDARD" && !var.network_options.public) ? 1 : 0 # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = local.resource_id
    hostname     = "${local.resource_id}.${local.domain}"
    machine_type = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    zone         = var.zone
    tags         = [local.tags]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';
            echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-${local.name}-${local.suffix}"
        source = google_compute_disk.this.name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${100 + local.index}"
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling}
    scheduling {
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart}
        preemptible         = false # [Default: "false"]
        automatic_restart   = true # [Default: "true"]
        on_host_maintenance = "MIGRATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model  = "STANDARD" # ["STANDARD", "SPOT"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.this[0].address }}
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
            bastion_host        = var.bastion-machine
            bastion_port        = 22
            bastion_user        = var.secrets.gce_ssh_user
            bastion_private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';",
            "echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "public_spot_vm" {
    count        = (local.gce_model == "SPOT" && var.network_options.public) ? 1 : 0 # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = local.resource_id
    hostname     = "${local.resource_id}.${local.domain}"
    machine_type = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    zone         = var.zone
    tags         = [local.tags]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';
            echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-${local.name}-${local.suffix}"
        source = google_compute_disk.this.name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${100 + local.index}"
        access_config {
            nat_ip = try(google_compute_address.this[0].address, "")
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
        preemptible                 = true # [Default: "false"]
        automatic_restart           = false # [Default: "true"]
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.this[0].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a}
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';",
            "echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "private_spot_vm" {
    count        = (local.gce_model == "SPOT" && !var.network_options.public) ? 1 : 0 # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name         = local.resource_id
    hostname     = "${local.resource_id}.${local.domain}"
    machine_type = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    zone         = var.zone
    tags         = [local.tags]

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';
            echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.e8s.io/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-${local.name}-${local.suffix}"
        source = google_compute_disk.this.name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${100 + local.index}"
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling}
    scheduling {
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart}
        preemptible                 = true # [Default: "false"]
        automatic_restart           = false # [Default: "true"]
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform}
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.this[0].address }}
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
            bastion_host        = var.bastion-machine
            bastion_port        = 22
            bastion_user        = var.secrets.gce_ssh_user
            bastion_private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname '${local.resource_id}.${local.domain}';",
            "echo '${local.resource_id}.${local.domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
