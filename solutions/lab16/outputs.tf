output "subnet_ids" {
  value = { for k, s in azurerm_subnet.main : k => s.id }
}

output "nat_public_ip" {
  value = azurerm_public_ip.nat.ip_address
}

output "vm_public_ip" {
  value = azurerm_public_ip.web.ip_address
}

output "vm_private_ip" {
  value = azurerm_linux_virtual_machine.web.private_ip_address
}

output "vm_private_only_ip" {
  value = azurerm_linux_virtual_machine.private.private_ip_address
}
