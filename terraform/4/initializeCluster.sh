#!/usr/bin/env bash
set -e
set -u

MASTER_IP=$( cd ../3; terraform output master_ipv4 )
SLAVE_INTERNAL_IP=$( cd ../3; terraform output host_0_private )
SLAVE_EXTERNAL_IP=$( cd ../3; terraform output host_0_public )

scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r conf core@$MASTER_IP:
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl label node $SLAVE_INTERNAL_IP loadBalancer=true
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sed --in-place s/--api-url-public-replace--/$SLAVE_EXTERNAL_IP/g conf/frontend.yml
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/nginx-ingress.yml
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/cassandra.yml
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/backend.yml
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/frontend.yml
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP rm -r conf

echo "Cluster set up done. After the containers are provisioned you can open the site up at http://$SLAVE_EXTERNAL_IP"
