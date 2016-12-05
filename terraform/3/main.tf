data "template_file" "master" {
  template = "${file("conf/master.conf")}"

  vars {
    etcd_discovery_url    = "${var.etcd_discovery_url}"
    kubernetes_version    = "${var.kubernetes_version}"
    kubectl_version       = "${var.kubectl_version}"
    dns_service_ip        = "${var.dns_service_ip}"
    kubernetes_service_ip = "${var.kubernetes_service_ip}"
    service_ip_range      = "${var.service_ip_range}"
    pod_network           = "${var.pod_network}"
  }
}

data "template_file" "node" {
  template = "${file("conf/node.conf")}"

  vars {
    etcd_discovery_url    = "${var.etcd_discovery_url}"
    kubernetes_version    = "${var.kubernetes_version}"
    dns_service_ip        = "${var.dns_service_ip}"
    kubernetes_service_ip = "${var.kubernetes_service_ip}"
    service_ip_range      = "${var.service_ip_range}"
    pod_network           = "${var.pod_network}"
    master_ip             = "${digitalocean_droplet.master.ipv4_address_private}"
  }
}

resource "digitalocean_ssh_key" "dodemo" {
  name       = "DO Demo Key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "digitalocean_droplet" "master" {
  image              = "coreos-beta"
  name               = "master"
  region             = "lon1"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.master.rendered}"
}

variable "node_size_config" {
  default = ["2gb", "2gb", "2gb", "2gb"]
}

resource "digitalocean_droplet" "node" {
  image              = "coreos-beta"
  name               = "node-${count.index}"
  region             = "lon1"
  size               = "${element(var.node_size_config, count.index)}"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.node.rendered}"

  # cannot copy files from one host to another, so we use a local command to generate the cert on master and copy it over to the worker
  provisioner "local-exec" {
    command = "${var.local_bash_shell_location} copy-keys.sh ${var.asset_path} ${digitalocean_droplet.master.ipv4_address} ${self.ipv4_address} ${self.name} ${self.ipv4_address_private}"
  }

  count = 3
}
