output "app_vm_private_ip" {
  description = "Private IP address of the application VM"
  value       = azurerm_network_interface.app.private_ip_address
}