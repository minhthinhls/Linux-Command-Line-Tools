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

variable "general_options" {
    type = object({
        name: string,
        tags: string,
        domain: string,
    })
    default = {
        name = "Compute-Engine" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags = "compute-engines" # ["bastion-machines", "load-balancers", "masters", "workers"].
        domain = "e8s.io" # [Compute-Engine Instance] Virtual-Machine [Host / Hostname] Domain.
    }
    description = "[Name / Tags] of Terraform Resources to be Provisioned by Google Cloud Platform."
}

variable "network_options" {
    type = object({
        subnet_range: string,
        public: bool,
    })
    default = {
        subnet_range = "172.16.0.0/24" # Private Network Range for Compute-Engine Instance assigned with Private IPs.
        public = true # Internet Expose Strategy of Compute-Engine Instance to be Provisioned by Google Cloud Platform.
    }
    description = "[Name / Tags] of Terraform Resources to be Provisioned by Google Cloud Platform."
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
        size = 100 # Gigabytes
        type = "pd-standard" # ["pd-standard", "pd-balanced", "pd-ssd"]
        # @description: Cannot specify both source image and source snapshot.
        image = "centos-cloud/centos-stream-8" # ["debian-cloud/debian-9"]
        # @description: Cannot specify both source image and source snapshot.
        snapshot = "snapshot-masters" # Snapshot Resources for Provisioning Boot Disks.
    }
    description = "Default Setting for Persistent attached with Disks Compute-Engine."
}

variable "gce_options" {
    type = object({
        machine_type: string,
        provisioning_model: string,
    })
    default = {
        machine_type = "e2-standard-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
        provisioning_model = "STANDARD" # ["STANDARD", "SPOT"].
    }
    description = "Default Setting for Compute-Engine Instance within Google Cloud Platform."
}

variable "index" {
    default     = 0 # Index started from [0].
    description = "Index of Compute-Engine Instance to be Provisioned by Google Cloud Platform."
}

variable "bastion-machine" {
    default     = "bastion-ingress.e8s.io"
    description = "Bastion Compute-Engine Instance to proxy SSH into Google Cloud Platform VPC."
}
