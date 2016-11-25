#!/usr/bin/env bash
terraform apply -var etcd_discovery_url=$(curl -w "\n" "https://discovery.etcd.io/new?size=1")
