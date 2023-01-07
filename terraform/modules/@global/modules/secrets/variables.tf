# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform Global Variable when executing Provisioners.
# @see {@link https://stackoverflow.com/questions/38645002/how-to-add-an-ssh-key-to-an-gcp-instance-using-terraform/}.
# @see {@link https://devops.stackexchange.com/questions/9815/use-terraform-to-manage-ssh-keys-in-gce/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------

variable "service_account" {
    type        = string
    default     = "service-account.json"
    description = "Relative Directory Path to the Google Cloud [Service_Account] Keyfile."
}

variable "ssh_users" {
    type        = list(string)
    default     = ["admin.e8s.io", "admin.ek8s.io", "admin.ek8s.net", "admin.ek8s.cc", "admin.ck8s.cc", "admin.ek8s.vip", "admin.xk8s.xyz"]
    description = "List SSH Username defined within OpenSSH Keyfile."
}

/** @type {Object<key:string => val:File>} ~!*/
variable "ssh_public_key_file" {
    default     = {}
    description = "Absolute Directory Path to the [Administrator] Public OpenSSH Keyfile."
}

/** @type {Object<key:string => val:File>} ~!*/
variable "ssh_private_key_file" {
    default     = {}
    description = "Absolute Directory Path to the [Administrator] Private OpenSSH Keyfile."
}
