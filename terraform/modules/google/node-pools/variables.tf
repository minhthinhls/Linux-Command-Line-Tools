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
    default     = 1 # Index started from [1].
    description = "Index of Compute-Engine Instance to be Provisioned by Google Cloud Platform."
}

variable "offset" {
    default     = 0 # Offset started from [0].
    description = "Index skipping value for Compute Instance. Ex: [offset=4] && [number=4] -> [master-05 -> master-08]"
}

// noinspection TFIncorrectVariableType
variable "node_pools" {
    type = list(object({
        availability_options = optional(object({
            region: optional(string), # ["asia-east2"] # HongKong [Regional].
            zone: optional(string), # ["asia-east2-a"] # HongKong [Zone::A].
        }), {}),
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
            type: string, # ["pd-standard", "pd-balanced", "pd-ssd"].
            image: optional(string), # ["centos-cloud/centos-stream-8", "debian-cloud/debian-9"].
            snapshot: optional(string), # ["snapshot-*"] Snapshot Resources for Provisioning Boot Disks.
        }),
        snapshot_options = optional(object({
            name: optional(string), # Example: ["snapshot-<tags>"] - Snapshot Resources for Provisioning Boot Disks.
            enable: optional(bool), # Example: Turn on this <flag> to snapshot the Persistent Disk of the specified Compute-Engine Instance.
            storage_locations: optional(list(string)), # Example: ["asia-east2"].
        }), {
            name = null
            enable = false,
            storage_locations = null
        }),
        index = optional(number), # Index started from [1].
        skip = optional(bool), # Ignore this resource.
    }))
    default = []
    description = "Amount of Compute-Engine Instance assigned with Public IPs."
}
