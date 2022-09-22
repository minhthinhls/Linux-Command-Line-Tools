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
        "worker-04" : "../worker-04/service-account.json",
    }
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

# ACCESS MODULE OUTPUT
# module.vpc-peering.current-network

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
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "ingress-01"
    credentials = local.credentials["ingress-01"]
    project = local.project_ids["ingress-01"]
}

module "vpc-peering-ingress-01" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.ingress-01 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["ingress-01"]
        project_id = local.project_ids["ingress-01"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["ingress-01"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["ingress-01"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "master-01"
    credentials = local.credentials["master-01"]
    project = local.project_ids["master-01"]
}

module "vpc-peering-master-01" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.master-01 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["master-01"]
        project_id = local.project_ids["master-01"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["master-01"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["master-01"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "worker-01"
    credentials = local.credentials["worker-01"]
    project = local.project_ids["worker-01"]
}

module "vpc-peering-worker-01" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.worker-01 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["worker-01"]
        project_id = local.project_ids["worker-01"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["worker-01"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-01"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "worker-02"
    credentials = local.credentials["worker-02"]
    project = local.project_ids["worker-02"]
}

module "vpc-peering-worker-02" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.worker-02 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["worker-02"]
        project_id = local.project_ids["worker-02"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["worker-02"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-02"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "worker-03"
    credentials = local.credentials["worker-03"]
    project = local.project_ids["worker-03"]
}

module "vpc-peering-worker-03" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.worker-03 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["worker-03"]
        project_id = local.project_ids["worker-03"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["worker-03"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-03"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @deprecated: Refactor Terraform Provider usage within `VPC-Peering` Module.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    alias = "worker-04"
    credentials = local.credentials["worker-04"]
    project = local.project_ids["worker-04"]
}

module "vpc-peering-worker-04" {
    source = "../../../modules/google/vpc-peering/"
    # providers = {
    #     google = google.worker-04 # [google.ingress-01, google.master-01, google.worker-01, ...];
    # }
    gcp_provider = {
        credential = local.credentials["worker-04"]
        project_id = local.project_ids["worker-04"]
    }
    current = "https://www.googleapis.com/compute/v1/projects/${local.project_ids["worker-04"]}/global/networks/global-vpc"
    others = [
        for project in setsubtract(toset(values(local.project_ids)), toset([local.project_ids["worker-04"]]))
        : "https://www.googleapis.com/compute/v1/projects/${project}/global/networks/global-vpc"
    ]
}
