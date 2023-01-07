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

variable "health_checks" {
    type = object({
        path: string,
        port: number,
    })
    default = {
        path = "/"
        port = 8081
    }
    description = "Health Check Options for Layer4 Network Load Balancer"
}

variable "endpoints" {
    type        = list(string)
    default     = []
    description = "Array of self-links of all target Load Balancer Endpoints"
}

variable "index" {
    default     = 1 # Index started from [1].
    description = "Index of IPv4 Instance to be Provisioned by Google Cloud Platform."
}

variable "offset" {
    default     = 0 # Offset started from [0].
    description = "Index skipping value for Compute Instance. Ex: [offset=4] && [number=4] -> [master-05 -> master-08]"
}

variable "general_options" {
    type = object({
        name: string,
        // noinspection TFIncorrectVariableType
        tags: optional(string),
    })
    default = {
        name = "External-Network-Load-Balancer" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
        tags = "external-network-load-balancers" # ["bastion-machines", "load-balancers", "masters", "workers"].
    }
    description = "[Name / Tags] of Terraform Resources to be Provisioned by Google Cloud Platform."
}

variable "provision_mode" {
    default     = "INITIALIZE" # ["INITIALIZE", "TERMINATED"].
    description = "[Optional] Controls the GCP Resources of forwarding Traffics to selected Backend Virtual Machine Instance."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Optional] Controls the method used to select Backend Virtual Machine Instance.
# @details: {@link https://cloud.google.com/load-balancing/docs/target-pools}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_pool#session_affinity}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "session_affinity" {
    default     = "NONE" # ["NONE", "CLIENT_IP", "CLIENT_IP_PROTO"].
    description = "[Optional] Controls the method used to select Backend Virtual Machine Instance."
}

// noinspection TFIncorrectVariableType
variable "config_pools" {
    type = list(object({
        availability_options = optional(object({
            region: optional(string), # ["asia-east2"] # HongKong [Regional].
            zone: optional(string), # ["asia-east2-a"] # HongKong [Zone::A].
        }), {}),
        general_options = optional(object({
            name: string, # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
            tags: string, # ["bastion-machines", "load-balancers", "masters", "workers"].
            domain: optional(string), # [Compute-Engine Instance] Virtual-Machine [Host / Hostname] Domain.
        }), {
            name = "External-Network-Load-Balancer" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
            tags = "external-network-load-balancers" # ["bastion-machines", "load-balancers", "masters", "workers"].
        }),
        network_options = optional(object({
            strategy: optional(string), # Example: ["L3", "L4"].
            protocol: optional(string), # Example: ["TCP", "UDP"]. Valid only for `Layer4` strategy.
            port_range: optional(string), # Example: ["30000-32768"]. Valid only for `Layer4` strategy.
        }), {
            strategy = "L3" # Example: ["L3", "L4"].
            port_range = null # Default [null] assume all ports [1-65536]. Otherwise specify only one port::"80"
        }),
        provision_options = optional(object({
            mode: string, # Example: ["IPV4_RESERVED", "FORWARDING_RULE_ENABLED"].
        }), {
            mode = "IPV4_RESERVED"
        }),
        index = optional(number), # Index started from [1].
        skip = optional(bool), # Ignore this resource.
    }))
    default = []
    description = "Amount of Compute-Engine Instance assigned with Public IPs."
}
