output "public_ip_address_ansible" {
  value = azurerm_linux_virtual_machine.practicePrivate_vm.public_ip_address
}

output "public_ip_address_public" {
  value = azurerm_linux_virtual_machine.practicePublic_vm.public_ip_address
}
