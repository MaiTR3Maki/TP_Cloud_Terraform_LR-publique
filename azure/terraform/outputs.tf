output "resource_group_id" {
  description = "L'ID du Resource Group créé"
  value       = azurerm_resource_group.tp.id
}

output "vnet_name" {
  description = "Le nom du réseau virtuel"
  value       = azurerm_virtual_network.tp.name
}

output "subnet_id" {
  description = "L'ID du subnet créé"
  value       = azurerm_subnet.tp.id
}

output "load_balancer_public_ip" {
  description = "IP publique du Load Balancer pour accéder au site"
  value       = azurerm_public_ip.lb_pip.ip_address
}
