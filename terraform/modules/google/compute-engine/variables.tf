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

variable "secrets" {
    type = object({
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
        /** @type {Object<key:string => val:File>} ~!*/
        ssh_public_key_file: map(string),
        /** @type {Object<key:string => val:File>} ~!*/
        ssh_private_key_file: map(string),
    })
    description = "[Service_Account] Credentials from [Google_Cloud] Providers."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Google Cloud Platform (GCP) Network Properties.
# @see {@link https://cloud.google.com/compute/docs/reference/rest/v1/networks/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "network" {
    type = object({
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @description: Network Instance as Google Cloud Platform (GCP) within Terraform Managed Resource Block.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        this: object({
            name: string,
            project: string,
            description: string,
            id: string, # Example: ["projects/<project_name>/global/networks/<network_name>"].
            self_link: string, # Example: ["https://www.googleapis.com/compute/v1/${id}"].
            mtu: number, # Default: [=0].
            routing_mode: string, # Example: ["REGIONAL"].
            gateway_ipv4: string,
            internal_ipv6_range: string,
            auto_create_subnetworks: bool,
            delete_default_routes_on_create: bool,
            enable_ula_internal_ipv6: bool,
            // noinspection TFIncorrectVariableType
            timeouts: optional(object({})),
        }),
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @description: This object has Regional Natural Name ["hongkong", "singapore", ...] as Key Attribute.
        # @example: [${var.network.sub_network["hongkong"]} -> ${google_compute_subnetwork}].
        # --------------------------------------------------------------------------------------------------------------------------------------------
        sub_network: map(object({
            name: string,
            role: string,
            project: string,
            description: string,
            id: string, # Example: ["projects/<project_name>/regions/<region_name>/subnetworks/<subnetwork_name>"].
            self_link: string, # Example: ["https://www.googleapis.com/compute/v1/${id}"].
            network: string, # Example: ["projects/<project_name>/global/networks/<network_name>"].
            region: string, # Example: ["asia-east2"].
            stack_type: string, # Example: ["IPV4_ONLY"].
            gateway_address: string, # Example: ["172.16.0.0"].
            ip_cidr_range: string, # Example: ["172.16.0.0/24"].
            secondary_ip_range: list(object({
                ip_cidr_range: string, # Example: ["192.168.0.0/24"].
                range_name: string, # Example: ["asia-east2-2"].
            })),
            purpose: string, # Example: ["PRIVATE"].
            log_config: list(any),
            ipv6_access_type: string,
            ipv6_cidr_range: string,
            external_ipv6_prefix: string,
            private_ip_google_access: bool,
            private_ipv6_google_access: string, # Example: ["DISABLE_GOOGLE_ACCESS"].
            creation_timestamp: string, # Example: ["2022-11-22T11:22:33.456-07:00"].
            // noinspection TFIncorrectVariableType
            fingerprint: optional(string), # Example: [Nullable<string_hash>].
            // noinspection TFIncorrectVariableType
            timeouts: optional(object({})),
        })),
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @alias: Referring as `${this}` property.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        global_vpc: object({
            name: string,
            project: string,
            description: string,
            id: string, # Example: ["projects/<project_name>/global/networks/<network_name>"].
            self_link: string, # Example: ["https://www.googleapis.com/compute/v1/${id}"].
            mtu: number, # Default: [=0].
            routing_mode: string, # Example: ["REGIONAL"].
            gateway_ipv4: string,
            internal_ipv6_range: string,
            auto_create_subnetworks: bool,
            delete_default_routes_on_create: bool,
            enable_ula_internal_ipv6: bool,
            // noinspection TFIncorrectVariableType
            timeouts: optional(object({})),
        }),
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @alias: Referring as `${sub_network.hongkong}` property.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        hongkong: object({
            name: string,
            role: string,
            project: string,
            description: string,
            id: string, # Example: ["projects/<project_name>/regions/<region_name>/subnetworks/<subnetwork_name>"].
            self_link: string, # Example: ["https://www.googleapis.com/compute/v1/${id}"].
            network: string, # Example: ["projects/<project_name>/global/networks/<network_name>"].
            region: string, # Example: ["asia-east2"].
            stack_type: string, # Example: ["IPV4_ONLY"].
            gateway_address: string, # Example: ["172.16.0.0"].
            ip_cidr_range: string, # Example: ["172.16.0.0/24"].
            secondary_ip_range: list(object({
                ip_cidr_range: string, # Example: ["192.168.0.0/24"].
                range_name: string, # Example: ["asia-east2-2"].
            })),
            purpose: string, # Example: ["PRIVATE"].
            log_config: list(any),
            ipv6_access_type: string,
            ipv6_cidr_range: string,
            external_ipv6_prefix: string,
            private_ip_google_access: bool,
            private_ipv6_google_access: string, # Example: ["DISABLE_GOOGLE_ACCESS"].
            creation_timestamp: string, # Example: ["2022-11-22T11:22:33.456-07:00"].
            // noinspection TFIncorrectVariableType
            fingerprint: optional(string), # Example: [Nullable<string_hash>].
            // noinspection TFIncorrectVariableType
            timeouts: optional(object({})),
        }),
    })
    description = "VPC Main Network Instance as Google Cloud Platform (GCP) Resource within Nested Terraform Object."
}

variable "index" {
    default     = 0 # Index started from [0].
    description = "Index of Compute-Engine Instance to be Provisioned by Google Cloud Platform."
}

variable "bastion_machine" {
    type        = string
    default     = null # "bastion-ingress.k8s.io"
    description = "Bastion Compute-Engine Instance to proxy SSH into Google Cloud Platform VPC."
}

variable "general_options" {
    type = object({
        name: string,
        tags: string,
        domain: string,
    })
    default = {
        name   = "Compute-Engine" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags   = "compute-engines" # ["bastion-machines", "load-balancers", "masters", "workers"].
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
        provisioning_model: string,
    })
    default = {
        machine_type = "e2-standard-2" # [["e2-standard-2"] -> ["2CPUs :: 8GBs RAM"]] && [["e2-highmem-2"] -> ["2CPUs :: 16GBs RAM"]]
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
        snapshot = "snapshot-masters" # Snapshot Resources for Provisioning Boot Disks.
    }
    description = "Default Setting for Persistent attached with Disks Compute-Engine."
}

variable "snapshot_options" {
    type = object({
        // noinspection TFIncorrectVariableType
        name: optional(string),
        // noinspection TFIncorrectVariableType
        enable: optional(bool),
        // noinspection TFIncorrectVariableType
        storage_locations: optional(list(string)),
    })
    default = {
        name = null # Example: ["snapshot-<tags>"] - Snapshot Resources for Provisioning Boot Disks.
        enable = false
        storage_locations = null
    }
    description = "Default Setting for Compute-Engine Snapshot within Google Cloud Platform."
}
