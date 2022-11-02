output "firewall" {
    value = module.firewall
    sensitive = true # Masked within Output Console Logger.
}

output "network" {
    value = module.network
    sensitive = true # Masked within Output Console Logger.
}

output "secrets" {
    value = module.secrets
    sensitive = true # Masked within Output Console Logger.
}

output "masters" {
    value = module.masters.self_links
}
