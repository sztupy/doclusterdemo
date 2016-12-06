#!/usr/bin/env bash
set -e
set -u

MASTER_IP=$( cd ../3; terraform output master_ipv4 )

ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl cluster-info 

echo "Setting up port forwarding, you should be able to access the sites above. Exit the shell if you are done"

ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -L 8080:localhost:8080 core@$MASTER_IP
