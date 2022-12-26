variable "region" {
    type        = string
    default     = "asia-east2" # HongKong
    # default   = "asia-southeast1" # Singapore
    description = "Google Cloud Platform Project Region."
}

variable "zone" {
    type        = string
    default     = "asia-east2-a" # HongKong [Zone::A].
    description = "Google Cloud Platform Project Availability Zones."
}

variable "region_code" {
    type        = map(string)
    default     = {
        hongkong = "asia-east2"
        singapore = "asia-southeast1"
    }
    description = "Google Cloud Platform Mapping for Availability Regional Code."
}

variable "machine_type" {
    type = object({
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @series: <GENERAL PURPOSE> — <SECOND GENERATION>. Machine Types for common Workloads that optimized within Cost and Flexibility.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        e2: map(string),
        n2: map(string),
        n2d: map(string),
        t2a: map(string),
        t2d: map(string),
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @series: <GENERAL PURPOSE> — <FIRST GENERATION>. Machine Types for common Workloads that optimized within Cost and Flexibility.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        n1: map(string),
    })
    default = {
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @series: <GENERAL PURPOSE> — <SECOND GENERATION>. Machine Types for common Workloads that optimized within Cost and Flexibility.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        e2  = {
            # @group: <SHARED-CORE>.
            "1-cpu-1gb-memory"    = "e2-micro"
            "1-cpu-2gb-memory"    = "e2-small"
            "1-cpu-4gb-memory"    = "e2-medium"
            # @group: <STANDARD>.
            "2-cpu-8gb-memory"    = "e2-standard-2"
            "4-cpu-16gb-memory"   = "e2-standard-4"
            "8-cpu-32gb-memory"   = "e2-standard-8"
            "16-cpu-64gb-memory"  = "e2-standard-16"
            "32-cpu-128gb-memory" = "e2-standard-32"
            # @group: <HIGH-CPU>.
            "2-cpu-2gb-memory"    = "e2-highcpu-2"
            "4-cpu-4gb-memory"    = "e2-highcpu-4"
            "8-cpu-8gb-memory"    = "e2-highcpu-8"
            "16-cpu-16gb-memory"  = "e2-highcpu-16"
            "32-cpu-32gb-memory"  = "e2-highcpu-32"
            # @group: <HIGH-MEMORY>.
            "2-cpu-16gb-memory"   = "e2-highmem-2"
            "4-cpu-32gb-memory"   = "e2-highmem-4"
            "8-cpu-64gb-memory"   = "e2-highmem-8"
            "16-cpu-128gb-memory" = "e2-highmem-16"
        }
        n2  = {}
        n2d = {}
        t2a = {}
        t2d = {}
        # --------------------------------------------------------------------------------------------------------------------------------------------
        # @series: <GENERAL PURPOSE> — <FIRST GENERATION>. Machine Types for common Workloads that optimized within Cost and Flexibility.
        # --------------------------------------------------------------------------------------------------------------------------------------------
        n1  = {}
    }
    description = "Google Cloud Platform (GCP) Mapping for Compute-Engine <Machine-Type> Resources."
}
