# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image}
# @see {@link https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = file(var.service_account)
    project = local.service_account["project_id"]
}

locals {
    service_account = merge(jsondecode(file(var.service_account)), {
        file_path: var.service_account
    })
    /** @type {Object<key:string => val:File>} ~!*/
    ssh_public_key_file = {
        for username in var.ssh_users : join("-", [
            lower(username),
        ]) => file("~/.ssh/${username}.open-ssh.pub")
    }
    /** @type {Object<key:string => val:File>} ~!*/
    ssh_private_key_file = {
        for username in var.ssh_users : join("-", [
            lower(username),
        ]) => file("~/.ssh/${username}.open-ssh.ppk")
    }
}
