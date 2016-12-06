output "master_ipv4" {
  value = "${digitalocean_droplet.master.ipv4_address}"
}

output "host_0_private" {
  value = "${digitalocean_droplet.node.0.ipv4_address_private}"
}

output "host_0_public" {
  value = "${digitalocean_droplet.node.0.ipv4_address}"
}

output "hosts" {
  value = <<HOSTS

${digitalocean_droplet.master.ipv4_address} master.local
${digitalocean_droplet.node.0.ipv4_address} node-0.local
${digitalocean_droplet.node.1.ipv4_address} node-1.local
${digitalocean_droplet.node.2.ipv4_address} node-2.local
HOSTS
}
