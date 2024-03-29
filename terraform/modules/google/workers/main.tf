# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Local Variables for Google Cloud Compute Engines.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    offset      = var.offset_instances # Instance Indexing Offset.
    expose      = var.reserved_external_ips # Instance Public Offset.
    region      = coalesce(var.region, module.default.region) # Fallback to default ${global.region} when ${var.region} got omitted.
    zone        = coalesce(var.zone, module.default.zone) # Fallback to default ${global.zone} when ${var.zone} got omitted.
    bastion_vm  = coalesce(var.bastion_machine, "bastion-01.${module.global.root_domain}") # Bastion Virtual Machine Endpoints.
    root_domain = coalesce(var.general_options.domain, module.global.root_domain) # Project Root Domain.
    subnet_range = split(".", var.subnet_range)
    subnet_prefix = join(".", slice(local.subnet_range, 0, length(local.subnet_range) - 1)) # Remove Last Segment. Ex: [172.16.0.0/24] -> [172.16.0]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Public IP Address within specific Region.
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address/}.
# @see {@link https://stackoverflow.com/questions/45359189/how-to-map-static-ip-to-terraform-google-compute-engine-instance/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "workers" {
    count           = var.reserved_external_ips # Switch to [1] to provision again.
    name            = "worker-${format("%02d", (count.index + local.offset) + 1)}"
    address_type    = "EXTERNAL" # ["INTERNAL", "EXTERNAL"]
    description     = "External-static-ipv4-for-Worker-${format("%02d", (count.index + local.offset) + 1)}"
    network_tier    = "PREMIUM" # ["PREMIUM", "STANDARD"]
    # @description: The field cannot be specified with external address.
    purpose         = null # ["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP", "VPC_PEERING", "IPSEC_INTERCONNECT", "PRIVATE_SERVICE_CONNECT"]
    # @description: [Regional / Zonal] Allocation.
    region          = local.region
    # zone          = local.zone # @argument named "zone" is not expected here.
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_disk" "workers" {
    count           = var.reserved_boot_disks # Switch to [1] to provision again.
    name            = "${var.disk_options.type}-worker-${format("%02d", (count.index + local.offset) + 1)}"
    type            = var.disk_options.type # ["pd-standard", "pd-balanced", "pd-ssd"]
    # @description: Cannot specify both source image and source snapshot.
    image           = try(var.disk_options.image, "") # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
    # @description: Cannot specify both source image and source snapshot.
    snapshot        = try(var.disk_options.snapshot, "")
    labels          = tomap({role = "workers"})
    size            = var.disk_options.size # Gigabytes
    # @description: [Regional / Zonal] Allocation.
    # region        = local.region # @argument named "region" is not expected here.
    zone            = local.zone
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "workers" {
    count           = ((var.number_instances > var.reserved_external_ips) ?
                       (var.reserved_external_ips) :
                       (var.number_instances)) # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name            = "worker-${format("%02d", (count.index + local.offset) + 1)}"
    hostname        = "worker-${format("%02d", (count.index + local.offset) + 1)}.${local.root_domain}"
    machine_type    = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    tags            = ["workers"]
    # @description: [Regional / Zonal] Allocation.
    # region        = local.region # @argument named "region" is not expected here.
    zone            = local.zone

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'worker-${format("%02d", (count.index + local.offset) + 1)}.${local.root_domain}';
            echo 'worker-${format("%02d", (count.index + local.offset) + 1)}.${local.root_domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.${local.root_domain}/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-Worker-${format("%02d", (count.index + local.offset) + 1)}"
        source = google_compute_disk.workers[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${(100 + count.index + local.offset) + 1}"
        access_config {
            nat_ip = try(google_compute_address.workers[count.index].address, "")
        }
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    scheduling {
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart/}.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        preemptible                 = true
        automatic_restart           = false
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.workers[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a/}.
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].access_config[0].nat_ip
            type        = "ssh"
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'worker-${format("%02d", (count.index + local.offset) + 1)}.${local.root_domain}';",
            "echo 'worker-${format("%02d", (count.index + local.offset) + 1)}.${local.root_domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform/issues/11770/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "private-workers" {
    count           = ((var.number_instances > var.reserved_external_ips) ?
                       (var.number_instances - var.reserved_external_ips) :
                       (0)) # Switch to [1] to provision again.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Reboot Google Cloud Compute Instance will not keep Hostname the same within `/etc/hostname`.
    # @see {@link https://stackoverflow.com/questions/49841511/change-hostname-permanently-in-google-compute-engine-instance-after-reboot/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    name            = "worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}"
    hostname        = "worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}.${local.root_domain}"
    machine_type    = var.gce_options.machine_type # [["e2-small"] -> ["2CPUs :: 2GBs RAM"]] && [["e2-custom-2-3072"] -> ["2CPUs :: 3GBs RAM"]]
    tags            = ["workers"]
    # @description: [Regional / Zonal] Allocation.
    # region        = local.region # @argument named "region" is not expected here.
    zone            = local.zone

    metadata = {
        ssh-keys = "${var.secrets.gce_ssh_user}:${file(var.secrets.gce_ssh_pub_key_file)}"
        startup-script = <<EOF
            sudo hostnamectl set-hostname 'worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}.${local.root_domain}';
            echo 'worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}.${local.root_domain}' | sudo tee /etc/hostname > /dev/null;
            sudo cp --force /root/.bashrc /home/admin.${local.root_domain}/.bashrc 2> /dev/null;
            sudo systemctl restart kubelet 2> /dev/null;
        EOF
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    boot_disk {
        auto_delete = false # Must not delete Boot Disk when Instance got terminated.
        device_name = "${upper(var.disk_options.type)}-Worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}"
        source = google_compute_disk.workers[count.index + local.expose].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = var.network.global_vpc.self_link
        subnetwork  = var.network.hongkong.self_link
        network_ip  = "${local.subnet_prefix}.${(100 + count.index + local.offset + local.expose) + 1}"
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.secrets.service_account["client_email"]
        scopes = ["cloud-platform"]
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#nested_scheduling/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    scheduling {
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#automatic_restart/}.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        preemptible                 = true
        automatic_restart           = false
        on_host_maintenance         = "TERMINATE" # ["MIGRATE", "TERMINATE"]
        provisioning_model          = "SPOT" # ["STANDARD", "SPOT"]
        instance_termination_action = "STOP" # ["DELETE", "STOP"]
    }

    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @see {@link https://stackoverflow.com/questions/68269560/how-to-run-a-bash-script-in-gcp-vm-using-terraform/}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    provisioner "remote-exec" {
        connection {
            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: Terraform GCP Remote-exec after creating Instance - gists · GitHub.
            # @deprecated: {{ host = google_compute_address.workers[count.index].address }}
            # @see {@link https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a/}.
            # ----------------------------------------------------------------------------------------------------------------------------------------
            host        = self.network_interface[0].network_ip
            type        = "ssh"
            user        = var.secrets.gce_ssh_user
            timeout     = "60s"
            private_key = file(var.secrets.gce_ssh_private_key_file)

            # ----------------------------------------------------------------------------------------------------------------------------------------
            # @description: SSH Through Kubernetes Cluster Bastion Machine.
            # @see {@link https://github.com/hashicorp/terraform/issues/18889/}.
            # @see {@link https://www.terraform.io/language/resources/provisioners/connection#connecting-through-a-bastion-host-with-ssh/}.
            # ----------------------------------------------------------------------------------------------------------------------------------------
            bastion_host        = local.bastion_vm
            bastion_port        = 22
            bastion_user        = var.secrets.gce_ssh_user
            bastion_private_key = file(var.secrets.gce_ssh_private_key_file)
        }

        inline = [
            "sudo hostnamectl set-hostname 'worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}.${local.root_domain}';",
            "echo 'worker-${format("%02d", (count.index + local.offset + local.expose) + 1)}.${local.root_domain}' | sudo tee /etc/hostname > /dev/null;",
        ]
    }

}
