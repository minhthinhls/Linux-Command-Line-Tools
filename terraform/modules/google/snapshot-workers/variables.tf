variable "network" {
    type = object({
        global_vpc: object({
            name: string,
            self_link: string,
        }),
        hongkong: object({
            name: string,
            self_link: string,
        }),
    })
    description = "GCP Main Network Mapper/Object."
}

variable "region" {
    type        = string
    default     = "asia-east2" # HongKong
    # default   = "asia-southeast1" # Singapore
    description = "Google Cloud Platform Project Region."
}

variable "zone" {
    type        = string
    default     = "asia-east2-a" # HongKong [Zone::A].
    description = "Google Cloud Platform Project Availability Zones."
}

variable "secrets" {
    type = object({
        gce_ssh_user: string,
        gce_ssh_pub_key_file: string,
        gce_ssh_private_key_file: string,
        service_account: object({
            type: string,
            project_id: string,
            private_key_id: string,
            private_key: string,
            client_email: string,
            client_id: string,
            auth_uri: string,
            token_uri: string,
            auth_provider_x509_cert_url: string,
            client_x509_cert_url: string,
            file_path: string,
        }),
    })
    description = "[Service_Account] Credentials from [Google_Cloud] Providers."
}

variable "disk_options" {
    type = object({
        size: number,
        type: string,
        // noinspection TFIncorrectVariableType
        image: optional(string),
        // noinspection TFIncorrectVariableType
        snapshot: optional(string),
    })
    default = {
        size = 100, # Gigabytes
        type = "pd-standard", # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-workers", # Snapshot Resources for Provisioning Boot Disks.
    }
    description = "Default Setting for Persistent attached with Disks Compute-Engine."
}

variable "gce_options" {
    type = object({
        machine_type: string,
    })
    default = {
        machine_type = "e2-standard-8" # [["e2-standard-4"] -> ["4CPUs :: 16GBs RAM"]] && [["e2-standard-8"] -> ["8CPUs :: 32GBs RAM"]]
    }
    description = "Default Setting for Compute-Engine Instance within Google Cloud Platform."
}

variable "snapshot_options" {
    type = object({
        name: string,
    })
    default = {
        name = "snapshot-workers"
    }
    description = "Default Setting for Persistent Disks Snapshot within Google Cloud Platform."
}

variable "subnet_range" {
    default     = "172.16.0.0/24"
    description = "Private Network Range for Compute-Engine Instance assigned with Private IPs."
}

variable "reserved_external_ips" {
    default     = 0
    description = "Amount of Compute-Engine Instance assigned with Public IPs."
}

variable "reserved_boot_disks" {
    default     = 0
    description = "Amount of Persistent Disks assigned with Compute-Engine Instance."
}

variable "offset_instances" {
    default     = 0
    description = "Index skipping value for Compute Instance. Ex: [offset=4] && [number=4] -> [worker-05 -> worker-08]"
}

variable "number_instances" {
    default     = 0
    description = "Amount of Compute-Engine Instance to be Provisioned by Google Cloud Platform."
}

variable "snapshots_instances" {
    default     = 0
    description = "Amount of [Boot-Disks Image Snapshots] following [Compute-Engine Persistent Disks] within Google Cloud Platform."
}
