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

output "load-balancers" {
    value = module.load-balancers.self_links
}

output "external-load-balancers" {
    value = module.external-load-balancers
}
