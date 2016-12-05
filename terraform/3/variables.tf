variable "access_key" {}

variable "etcd_discovery_url" {}

variable "local_bash_shell_location" {
  default = "/usr/bin/env bash"
}

variable "asset_path" {
  default = "tmp"
}

variable "kubernetes_version" {
  default = "v1.4.3_coreos.0"
}

variable "kubectl_version" {
  default = "v1.4.3"
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
