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

variable "subnet_range" {
    default     = "172.16.0.0/24"
    description = "Private Network Range for Compute-Engine Instance assigned with Private IPs."
}

variable "index" {
    default     = 1 # Index started from [0].
    description = "Index of Compute-Engine Instance to be Provisioned by Google Cloud Platform."
}

variable "offset" {
    default     = 0 # Offset started from [0].
    description = "Index skipping value for Compute Instance. Ex: [offset=4] && [number=4] -> [master-05 -> master-08]"
}

// noinspection TFIncorrectVariableType
variable "node_pools" {
    type = list(object({
        general_options = object({
            name: string, # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
            tags: string, # ["bastion-machines", "load-balancers", "masters", "workers"].
            domain: optional(string), # [Compute-Engine Instance] Virtual-Machine [Host / Hostname] Domain.
        }),
        network_options = object({
            subnet_range: optional(string), # ["172.16.0.0/24"] Private Network Range for Compute-Engine Instance assigned with Private IPs.
            public: optional(bool), # Internet Expose Strategy of Compute-Engine Instance to be Provisioned by Google Cloud Platform.
        }),
        gce_options = object({
            machine_type: optional(string), # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]].
            provisioning_model: optional(string), # ["STANDARD", "SPOT"].
        }),
        disk_options = object({
            size: number, # Gigabytes
            type: string, # ["pd-standard", "pd-balanced", "pd-ssd"]
            image: optional(string), # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"]
            snapshot: optional(string), # ["snapshot-*"] Snapshot Resources for Provisioning Boot Disks.
        }),
        index = optional(number), # Index started from [1].
    }))
    default = []
    description = "Amount of Compute-Engine Instance assigned with Public IPs."
}
