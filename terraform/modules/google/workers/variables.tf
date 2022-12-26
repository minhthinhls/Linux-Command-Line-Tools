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

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @warning: Keyword "optional" is valid only as a modifier for Object type Attributes.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "region" {
    type        = string
    default     = null
    description = "Google Cloud Platform Project Region."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @warning: Keyword "optional" is valid only as a modifier for Object type Attributes.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "zone" {
    type        = string
    default     = null
    description = "Google Cloud Platform Project Availability Zones."
}

variable "bastion_machine" {
    type        = string
    default     = null # "bastion-ingress.k8s.io"
    description = "Bastion Compute-Engine Instance to proxy SSH into Google Cloud Platform VPC."
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
        name   = "Worker" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags   = "workers" # ["bastion-machines", "load-balancers", "masters", "workers"].
        domain = null # [Compute-Engine Instance] Virtual-Machine [Host / Hostname] Domain.
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
    description = "Networking Properties of Terraform Resources to be Provisioned by Google Cloud Platform."
}

variable "gce_options" {
    type = object({
        machine_type: string,
        // noinspection TFIncorrectVariableType
        provisioning_model: optional(string),
    })
    default = {
        machine_type = "e2-standard-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]].
        provisioning_model = "STANDARD" # ["STANDARD", "SPOT"].
    }
    description = "Default Setting for Compute-Engine Instance within Google Cloud Platform."
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
        snapshot = "snapshot-workers" # Snapshot Resources for Provisioning Boot Disks.
    }
    description = "Default Setting for Persistent attached with Disks Compute-Engine."
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
