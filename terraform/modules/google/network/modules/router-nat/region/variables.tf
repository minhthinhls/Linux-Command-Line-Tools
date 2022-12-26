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
    })
    description = "VPC Main-Network Instance."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Google Cloud Platform (GCP) Network Properties.
# @see {@link https://cloud.google.com/compute/docs/reference/rest/v1/networks/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "subnetwork" {
    type = object({
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
    })
    description = "VPC Sub-Network Instance."
}
