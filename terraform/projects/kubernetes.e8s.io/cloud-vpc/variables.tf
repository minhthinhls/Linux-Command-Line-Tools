# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Terraform Variable Resources.
# @see {@link https://www.terraform.io/language/expressions/type-constraints/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
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
