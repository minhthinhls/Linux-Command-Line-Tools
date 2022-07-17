# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Google Cloud Compute Instance Disk from Snapshot.
# @see {@link https://github.com/hashicorp/terraform-provider-google/issues/5428}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
resource "google_filestore_instance" "shared_disks" {
    count       = 0 # Switch to [1] to provision again.
    name        = "shared-disk-0${count.index + 1}"
    tier        = "BASIC_HDD" # ["STANDARD", "PREMIUM", "BASIC_HDD", "BASIC_SSD", "HIGH_SCALE_SSD", "ENTERPRISE"]
    location    = var.zone

    file_shares {
        capacity_gb = 2560 # Gigabytes
        name        = "volume"

        nfs_export_options {
            ip_ranges = ["172.16.0.254/32"]
            access_mode = "READ_WRITE"
            squash_mode = "NO_ROOT_SQUASH"
        }

        nfs_export_options {
            ip_ranges = ["172.16.0.253/32"]
            access_mode = "READ_ONLY"
            squash_mode = "ROOT_SQUASH"
            anon_uid = 123
            anon_gid = 456
        }
    }

    networks {
        network = google_compute_network.main_network.id
        modes   = ["MODE_IPV4"]
        connect_mode = "DIRECT_PEERING"
    }
}
