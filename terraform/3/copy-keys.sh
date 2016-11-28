#!/usr/bin/env bash
set -e
set -u

ASSET_PATH=$1
FROM_IP=$2
TO_IP=$3
NAME=$4
CN_IP=$5

mkdir -p $ASSET_PATH

ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$FROM_IP sudo /root/bootstrap/generate-worker-cert.sh $NAME $CN_IP

scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$FROM_IP:/home/core/$NAME-worker-key.pem $ASSET_PATH
scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$FROM_IP:/home/core/$NAME-worker.pem $ASSET_PATH
scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$FROM_IP:/home/core/$NAME-ca.pem $ASSET_PATH

scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $ASSET_PATH/$NAME-worker-key.pem core@$TO_IP:/home/core/worker-key.pem
scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $ASSET_PATH/$NAME-worker.pem core@$TO_IP:/home/core/worker.pem
scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $ASSET_PATH/$NAME-ca.pem core@$TO_IP:/home/core/ca.pem

rm $ASSET_PATH/$NAME-worker.pem $ASSET_PATH/$NAME-worker-key.pem $ASSET_PATH/$NAME-ca.pem

ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null core@$FROM_IP rm /home/core/$NAME-worker-key.pem /home/core/$NAME-worker.pem /home/core/$NAME-ca.pem
