/** @documentation: [Service_Account] Credentials as [Terraform] Type Declaration. ~!*/
variable "service_account_credentials" {
    // noinspection TFIncorrectVariableType ~!*/
    type = object({
        type: string,
        project_id: string,
        private_key_id: string,
        private_key: string,
        client_email: string,
        client_id: string,
        auth_uri: string,
        token_uri: string,
        auth_provider_x509_cert_url: string,
        client_x509_cert_url: string,
        file_path: string,
    })
    default     = null
    description = "[Service_Account] Credentials as [Terraform] Type Declaration."
}

output "service_account" {
    value = local.service_account
    description = "[Service_Account] Credentials from [Google_Cloud] Providers."
}

/** @type {Object<key:string => val:File>} ~!*/
output "ssh_public_key_file" {
    value = merge(var.ssh_public_key_file, local.ssh_public_key_file)
}

/** @type {Object<key:string => val:File>} ~!*/
output "ssh_private_key_file" {
    value = merge(var.ssh_private_key_file, local.ssh_private_key_file)
}
