output "self_links" {
    value = flatten([
        [for name, node in module.nodes : node.self_links],
    ])
}
