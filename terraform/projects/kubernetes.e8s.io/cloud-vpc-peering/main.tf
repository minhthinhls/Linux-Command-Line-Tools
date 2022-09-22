# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform Root Provider.
# @see {@link https://www.terraform.io/language/modules/syntax/}
# @see {@link https://www.terraform.io/language/modules/develop/providers/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = file(module.secrets.service_account["file_path"])
    project = module.secrets.service_account["project_id"]
    region  = var.region
    zone    = var.zone
}

module "secrets" {
    source = "../../../modules/google/secrets"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform For-Loop Statements.
# @see {@link https://www.terraform.io/language/expressions/for/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    credentials = {for project, service_account in var.projects : project => file(service_account)}
    service_accounts = {for project, service_account in var.projects : project => jsondecode(file(service_account))}
    project_ids = {for project, service_account in var.projects : project => jsondecode(file(service_account))["project_id"]}
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "ingress-01"
    credentials = local.credentials["ingress-01"]
    project = local.project_ids["ingress-01"]
}

module "vpc-peering" {
    source = "../../../modules/google/vpc-peering/"
    for_each = var.projects # @alternative: flatten([keys(var.projects)])
    gcp_provider = {
        credential = local.credentials[each.key]
        project_id = local.project_ids[each.key]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids[each.key]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids[each.key]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}
