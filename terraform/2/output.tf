output "frontend_ipv4" {
  value = "${digitalocean_droplet.frontend.ipv4_address}"
}

output "api_ipv4" {
  value = "${digitalocean_droplet.api.ipv4_address}"
}

output "hosts" {
  value = <<HOSTS

${digitalocean_droplet.frontend.ipv4_address} frontend.local
${digitalocean_droplet.api.ipv4_address} api.local
HOSTS
}
