#!/usr/bin/env bash
set -e
set -u

MASTER_IP=$( cd ../3; terraform output master_ipv4 )
SLAVE_INTERNAL_IP=$( cd ../3; terraform output host_0_private )

ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete rc --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete ingress --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete service --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete deployment --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete petset --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl delete pod --all
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl label node $SLAVE_INTERNAL_IP loadBalancer-

echo "Cluster decomissioned"
