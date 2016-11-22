output "frontend_ipv4" {
  value = "${digitalocean_droplet.frontend.ipv4_address}"
}

output "api_ipv4" {
  value = "${digitalocean_droplet.api.ipv4_address}"
}

output "hosts" {
  value = <<HOSTS

${digitalocean_domain.default.ip_address} ${var.domain_name}
${digitalocean_record.api.value} api.${var.domain_name}
HOSTS
}
