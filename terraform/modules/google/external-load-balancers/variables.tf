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

variable "general_options" {
    type = object({
        name: string,
    })
    default = {
        name = "External-Network-Load-Balancer" # ["Bastion-Machine", "Load-Balancer", "Master", "Worker"].
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
