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
    count       = var.snapshot_worker_instances.number_instances # Switch to [1] to provision again.
    name        = "ssd-worker-0${count.index}"
    zone        = "asia-east2-a" # "${var.zone}"
    type        = "pd-ssd" # ["pd-standard", "pd-balanced", "pd-ssd"]
    # @description: Cannot specify both source image and source snapshot.
    # image       = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
    snapshot    = "snapshot-workers"
    labels      = tomap({role = "workers"})
    size        = 20 # Gigabytes
}

resource "google_compute_instance" "snapshot-workers" {
    count        = var.snapshot_worker_instances.number_instances # Switch to [1] to provision again.
    name         = "worker-0${count.index}"
    hostname     = "worker-0${count.index}.e8s.io"
    machine_type = "e2-small"
    tags         = ["workers"]

    metadata = {
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    }

    # @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance}
    boot_disk {
        device_name = "SSD-Worker-0${count.index}"
        source = google_compute_disk.snapshot-workers[count.index].name
    }

    network_interface {
        # A default network is created for all GCP projects
        network     = google_compute_network.main_network.self_link
        subnetwork  = google_compute_subnetwork.sub_network.self_link
        network_ip  = "172.16.2.${count.index}"
        access_config {
            nat_ip = google_compute_address.snapshot-workers[count.index].address
        }
    }
}
