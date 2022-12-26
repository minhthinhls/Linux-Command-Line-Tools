output "region" {
    value       = var.region
    description = "Google Cloud Platform Project Region."
}

output "zone" {
    value       = var.zone
    description = "Google Cloud Platform Project Availability Zones."
}

output "region_code" {
    value       = var.region_code
    description = "Google Cloud Platform Mapping for Availability Regional Code."
}

output "machine_type" {
    value       = var.machine_type
    description = "Google Cloud Platform (GCP) Mapping for Compute-Engine <Machine-Type> Resources."
}
