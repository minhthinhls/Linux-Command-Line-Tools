# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @warning: Keyword "optional" is valid only as a modifier for Object type Attributes.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "name" {
    type        = string
    default     = "global-vpc"
    description = "Google Cloud Platform (GCP) Main Network."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @warning: Keyword "optional" is valid only as a modifier for Object type Attributes.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "auto_create_subnetworks" {
    type        = bool
    default     = false
    description = "Google Cloud Platform (GCP) Main Network Optional Attribute."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @warning: Keyword "optional" is valid only as a modifier for Object type Attributes.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "routing_mode" {
    type        = string
    default     = "REGIONAL"
    description = "Google Cloud Platform (GCP) Main Network Optional Attribute."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @targeted: Migrate to ${var.subnet_ip_cidr_range.*.*} as the latest arguments.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "subnet_ip_cidr_range" {
    type = object({
        hongkong: object({
            primary: string,
            secondary: list(string),
        }),
        singapore: object({
            primary: string,
            secondary: list(string),
        }),
    })
    default = {
        hongkong = {
            primary = "172.16.0.0/16"
            secondary = ["192.168.0.0/16"]
        }
        singapore = {
            primary = "172.18.0.0/16"
            secondary = ["10.18.0.0/16"]
        }
    }
    description = "Google Cloud Platform Subnet IPs CIDR."
}
