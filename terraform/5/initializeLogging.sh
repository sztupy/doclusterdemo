#!/usr/bin/env bash
set -e
set -u

MASTER_IP=$( cd ../3; terraform output master_ipv4 )
SLAVE_IPS=$( cd ../3; terraform output host_public_ips )

# install fluentd logging driver to all slaves
for SL_IP in $SLAVE_IPS; do
  scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null conf/fluentd-es.yaml core@$SL_IP:
  ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$SL_IP sudo mv fluentd-es.yaml /etc/kubernetes/manifests/
done

# install fluentd logging driver to master and install supporting architecture
scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r conf core@$MASTER_IP:
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo cp conf/fluentd-es.yaml /etc/kubernetes/manifests/
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/es.yaml || true
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP sudo /opt/bin/kubectl create -f conf/kibana.yaml || true
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$MASTER_IP rm -r conf

echo "Logging drivers set up"
