variable "service_account" {
    type        = string
    default     = "service-account.json"
    description = "Relative Directory Path to the Google Cloud [Service_Account] Keyfile."
}

variable "gce_ssh_user" {
    type        = string
    default     = "admin.e8s.io"
    description = "Username defined within OpenSSH Keyfile."
}

variable "gce_ssh_pub_key_file" {
    default     = "~/.ssh/admin.e8s.io.open-ssh.pub"
    description = "Absolute Directory Path to the [Administrator] Public OpenSSH Keyfile."
}

variable "gce_ssh_private_key_file" {
    default     = "~/.ssh/admin.e8s.io.open-ssh.ppk"
    description = "Absolute Directory Path to the [Administrator] Private OpenSSH Keyfile."
}
