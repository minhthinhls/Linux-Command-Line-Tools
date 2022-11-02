# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
variable "projects" {
    type        = map(string)
    description = "All Projects Service Account Paths"
    default     = {
        "ingress-01": "../ingress-01/service-account.json",
        "master-01" : "../master-01/service-account.json",
        "worker-01" : "../worker-01/service-account.json",
        "worker-02" : "../worker-02/service-account.json",
        "worker-03" : "../worker-03/service-account.json",
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform Variable Resources.
# @see {@link https://www.terraform.io/language/expressions/type-constraints/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
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
