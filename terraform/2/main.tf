resource "digitalocean_domain" "default" {
  name       = "${var.domain_name}"
  ip_address = "${digitalocean_droplet.frontend.ipv4_address}"
}

resource "digitalocean_record" "api" {
  domain = "${digitalocean_domain.default.name}"
  type   = "A"
  name   = "api"
  value  = "${digitalocean_droplet.api.ipv4_address}"
}

data "template_file" "frontend" {
  template = "${file("conf/frontend.conf")}"

  vars {
    api_url = "${digitalocean_droplet.api.ipv4_address}"
  }
}

data "template_file" "api" {
  template = "${file("conf/api.conf")}"

  vars {
    backend_urls  = "${join(",",digitalocean_droplet.backend.*.ipv4_address_private)}"
    backend_names = "${join(",",digitalocean_droplet.backend.*.name)}"
  }
}

data "template_file" "backend" {
  template = "${file("conf/backend.conf")}"

  vars {
    cassandra_urls = "${join(",",concat(list(digitalocean_droplet.cassandra_master.ipv4_address_private),digitalocean_droplet.cassandra_slave.*.ipv4_address_private))}"
  }
}

data "template_file" "cassandra_master" {
  template = "${file("conf/cassandra.conf")}"

  vars {
    cassandra_master_config = ""
  }
}

data "template_file" "cassandra_slave" {
  template = "${file("conf/cassandra.conf")}"

  vars {
    cassandra_master_config = "${format("-e CASSANDRA_SEEDS=%s",digitalocean_droplet.cassandra_master.ipv4_address_private)}"
  }
}

resource "digitalocean_droplet" "frontend" {
  image              = "coreos-stable"
  name               = "frontend"
  region             = "lon1"
  size               = "512mb"
  private_networking = false
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.frontend.rendered}"
}

resource "digitalocean_droplet" "api" {
  image              = "coreos-stable"
  name               = "api"
  region             = "lon1"
  size               = "512mb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.api.rendered}"
}

resource "digitalocean_droplet" "backend" {
  image              = "coreos-stable"
  name               = "backend-${count.index}"
  region             = "lon1"
  size               = "512mb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.backend.rendered}"

  count = 2
}

resource "digitalocean_droplet" "cassandra_master" {
  image              = "coreos-stable"
  name               = "cassandra-${count.index}"
  region             = "lon1"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.cassandra_master.rendered}"
}

resource "digitalocean_droplet" "cassandra_slave" {
  image              = "coreos-stable"
  name               = "cassandra-${count.index+1}"
  region             = "lon1"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.cassandra_slave.rendered}"

  count = 1
}
