variable "access_key" {}

variable "domain_name" {}

provider "digitalocean" {
  token = "${var.access_key}"
}

resource "digitalocean_ssh_key" "dodemo" {
  name       = "DO Demo Key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "digitalocean_domain" "default" {
  name       = "${var.domain_name}"
  ip_address = "${digitalocean_droplet.web.ipv4_address}"
}

resource "digitalocean_droplet" "web" {
  image              = "coreos-stable"
  name               = "web"
  region             = "lon1"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${file("web.conf")}"
}

output "main_ipv4" {
  value = "${digitalocean_droplet.web.ipv4_address}"
}

output "hosts" {
  value = <<HOSTS

${digitalocean_domain.default.ip_address} ${var.domain_name}
HOSTS
}
