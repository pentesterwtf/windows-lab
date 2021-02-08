# outputs.tf

# Defines outputs of our playbooks
output "pdc_host_address" {
  value       = libvirt_domain.domain-windows-server-2019-pdc.network_interface[0].addresses[0]
  description = "The private IP address of the main domain controller"
}

output "kali_host_address" {
  value       = libvirt_domain.domain-kali[*].network_interface[0].addresses[0]
  description = "The private IP address of all kali hosts."
}

output "win10_host_address" {
  value       = libvirt_domain.domain-windows10[*].network_interface[0].addresses[0]
  description = "The private IP address of all win10 hosts."
}
output "win2019_host_address" {
  value       = libvirt_domain.domain-windows-server-2019[*].network_interface[0].addresses[0]
  description = "The private IP address of all server 2019 hosts, excluding the primary domain controller."
}

