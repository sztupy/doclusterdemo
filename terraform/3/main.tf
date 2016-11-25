variable "access_key" {}

variable "domain_name" {}

variable "etcd_discovery_url" {}

variable "asset_path" {
  default = "tmp"
}

variable "kubernetes_version" {
  default = "v1.4.3_coreos.0"
}

variable "dns_service_ip" {
  default = "10.3.0.10"
}

variable "kubernetes_service_ip" {
  default = "10.3.0.1"
}

variable "service_ip_range" {
  default = "10.3.0.0/24"
}

variable "pod_network" {
  default = "10.2.0.0/16"
}

provider "digitalocean" {
  token = "${var.access_key}"
}

data "template_file" "master" {
  template = "${file("conf/master.conf")}"

  vars {
    etcd_discovery_url    = "${var.etcd_discovery_url}"
    kubernetes_version    = "${var.kubernetes_version}"
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

resource "digitalocean_domain" "default" {
  name       = "${var.domain_name}"
  ip_address = "${digitalocean_droplet.master.ipv4_address}"
}

resource "digitalocean_droplet" "master" {
  image              = "coreos-stable"
  name               = "master"
  region             = "lon1"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.master.rendered}"
}

variable "node_size_config" {
  default = ["512mb", "512mb", "512mb", "2gb", "2gb"]
}

resource "digitalocean_droplet" "node" {
  image              = "coreos-stable"
  name               = "node-${count.index}"
  region             = "lon1"
  size               = "${element(var.node_size_config, count.index)}"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]
  user_data          = "${data.template_file.node.rendered}"

  # cannot copy files from one host to another, so we use a local command to generate the cert on master and copy it over to the worker
  provisioner "local-exec" {
    command = <<CMD
      mkdir -p ${var.asset_path} \
        && ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@${digitalocean_droplet.master.ipv4_address} sudo /root/bootstrap/generate-worker-cert.sh ${self.name} ${self.ipv4_address} \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@${digitalocean_droplet.master.ipv4_address}:/home/core/${self.name}-worker-key.pem ${var.asset_path} \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@${digitalocean_droplet.master.ipv4_address}:/home/core/${self.name}-worker.pem ${var.asset_path} \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@${digitalocean_droplet.master.ipv4_address}:/home/core/${self.name}-ca.pem ${var.asset_path} \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null ${var.asset_path}/${self.name}-worker-key.pem core@${self.ipv4_address}:/home/core/worker-key.pem \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null ${var.asset_path}/${self.name}-worker.pem core@${self.ipv4_address}:/home/core/worker.pem \
        && scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null ${var.asset_path}/${self.name}-ca.pem core@${self.ipv4_address}:/home/core/ca.pem \
        && rm ${var.asset_path}/${self.name}-worker.pem ${var.asset_path}/${self.name}-worker-key.pem ${var.asset_path}/${self.name}-ca.pem \
        && ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@${digitalocean_droplet.master.ipv4_address} rm /home/core/${self.name}-worker-key.pem /home/core/${self.name}-worker.pem /home/core/${self.name}-ca.pem
CMD
  }

  count = 1
}

output "master_ipv4" {
  value = "${digitalocean_droplet.master.ipv4_address}"
}

output "node_ipv4" {
  value = "${digitalocean_droplet.node.0.ipv4_address}"
}

output "hosts" {
  value = <<HOSTS

${digitalocean_domain.default.ip_address} ${var.domain_name}
HOSTS
}
