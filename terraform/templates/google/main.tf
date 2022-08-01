# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = file(var.service_account)
    project = local.service_account["project_id"]
    region  = var.region
    zone    = var.zone
}

locals {
    service_account = jsondecode(file(var.service_account))
}

variable "service_account" {
    type    = string
    default = "service-account.json"
}

variable "gce_ssh_user" {
    type    = string
    default = "admin.e8s.io"
}

variable "gce_ssh_pub_key_file" {
    default = "~/.ssh/admin.e8s.io.open-ssh.pub"
}

variable "gce_ssh_private_key_file" {
    default = "~/.ssh/admin.e8s.io.open-ssh.ppk"
}

variable "region" {
    type    = string
    default = "asia-east2" # HongKong
    # default = "asia-southeast1" # Singapore
}

variable "zone" {
    type    = string
    default = "asia-east2-a" # HongKong [Zone::A].
}

# @command >> gcloud auth login --no-launch-browser
# @command >> gcloud config set project kubernetes-e8s-io
# @command >> gcloud compute images list --filter=centos

variable "snapshot_load_balancer_instances" {
    default = {
        reserved_external_ips = 0
        reserved_boot_disks = 0
        number_instances = 0
    }
}

variable "snapshot_master_instances" {
    default = {
        reserved_external_ips = 0
        reserved_boot_disks = 0
        number_instances = 0
    }
}

variable "snapshot_worker_instances" {
    default = {
        reserved_external_ips = 0
        reserved_boot_disks = 0
        number_instances = 0
    }
}

variable "keep_alived_instances" {
    default = {
        reserved_external_ips = 1
        number_instances = 0
    }
}

variable "load_balancer_instances" {
    default = {
        reserved_external_ips = 2
        reserved_boot_disks = 2
        number_instances = 2
    }
}

variable "master_instances" {
    default = {
        reserved_external_ips = 3
        reserved_boot_disks = 3
        number_instances = 3
    }
}

variable "worker_instances" {
    default = {
        reserved_external_ips = 0
        reserved_boot_disks = 6
        number_instances = 6
    }
}

output "debug" {
    value = true
}
