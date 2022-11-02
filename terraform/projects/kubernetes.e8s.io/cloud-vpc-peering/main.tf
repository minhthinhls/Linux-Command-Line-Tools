# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform Root Provider.
# @see {@link https://www.terraform.io/language/modules/syntax/}
# @see {@link https://www.terraform.io/language/modules/develop/providers/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    region  = var.region
    zone    = var.zone
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform For-Loop Statements.
# @see {@link https://www.terraform.io/language/expressions/for/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
locals {
    credentials      = {for project, service_account in var.projects : project => file(service_account)}
    service_accounts = {for project, service_account in var.projects : project => jsondecode(file(service_account))}
    project_ids      = {for project, service_account in var.projects : project => jsondecode(file(service_account))["project_id"]}
}

/* @description: Cannot use [for_each, count, depends_on] when module has its own `provider` emerged within.
module "vpc-peering" {
    source = "../../../modules/google/vpc-peering/"
    for_each = var.projects # @alternative: flatten([keys(var.projects)])
    gcp_provider = {
        credential = local.credentials[each.key]
        project_id = local.project_ids[each.key]
    }
    current = local.project_ids[each.key]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids[each.key]]))
}
*/

module "vpc-peering-ingress-01" {
    source = "../../../modules/google/vpc-peering/"
    gcp_provider = {
        credential = local.credentials["ingress-01"]
        project_id = local.project_ids["ingress-01"]
    }
    current = local.project_ids["ingress-01"]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids["ingress-01"]]))
}

module "vpc-peering-master-01" {
    source = "../../../modules/google/vpc-peering/"
    gcp_provider = {
        credential = local.credentials["master-01"]
        project_id = local.project_ids["master-01"]
    }
    current = local.project_ids["master-01"]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids["master-01"]]))
}

module "vpc-peering-worker-01" {
    source = "../../../modules/google/vpc-peering/"
    gcp_provider = {
        credential = local.credentials["worker-01"]
        project_id = local.project_ids["worker-01"]
    }
    current = local.project_ids["worker-01"]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-01"]]))
}

module "vpc-peering-worker-02" {
    source = "../../../modules/google/vpc-peering/"
    gcp_provider = {
        credential = local.credentials["worker-02"]
        project_id = local.project_ids["worker-02"]
    }
    current = local.project_ids["worker-02"]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-02"]]))
}

module "vpc-peering-worker-03" {
    source = "../../../modules/google/vpc-peering/"
    gcp_provider = {
        credential = local.credentials["worker-03"]
        project_id = local.project_ids["worker-03"]
    }
    current = local.project_ids["worker-03"]
    others = setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-03"]]))
}
