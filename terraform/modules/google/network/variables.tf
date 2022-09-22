variable "region" {
    type        = string
    description = "Google Cloud Platform Project Region."
}

variable "subnet_ips" {
    type        = list(string)
    description = "Google Cloud Platform Subnet IPs CIDR."
}
