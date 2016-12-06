#!/bin/bash
#
# Project files from https://github.com/k8s-for-greeks/gpmr/blob/master/pet-race-devops/docker/cassandra-debian/Dockerfile
# Modified to be able to use docker hub's openjdk instead of the hidden one present inside the dockerfiles

docker build -t doclusterdemo/cassandra-pet:3.7 .
