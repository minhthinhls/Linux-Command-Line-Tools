variable "current" {
    type        = string
    description = "GCP Network Self Link of current Provider."
}

variable "others" {
    type        = set(string)
    description = "GCP Network Self Links from other Providers."
}
