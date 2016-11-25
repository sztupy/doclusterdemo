Kubernetes cluster
==================

In the previous example we made sure our appliction can work in a multi-node environment,
so now let's try to make our nodes more dynamic. Here we'll be setting up kubernetes,
a container orchestration system.

Kubernetes relies on `etcd`, which is a distributed key-value configuration store, so we
have to make sure our cluster has them up and running, and can access each other. Etcd
has a nice online tool that it can use so nodes can discover each other. You can simply
download a specific key from it, and your nodes will use that to find each other.

To get a key, simply open up `https://discovery.etcd.io/new?size=1` in a browser. The
size parameter says how many master etcd nodes we want in our cluster. The rest of the
nodes will also run etcd but only in proxy mode.

As usual you can simply run `terraform plan` and `terraform apply`, to check and deploy
the sites. The deployment will ask you for the etcd key url, which you have to supply.
Alternatively just run `./apply.sh` which will download a new etcd key every time you
run apply. Please note this will only work on the first setup call, as any additional
call to `terraform apply` will result in a different key, which is not desirable,
as the new machines will not know where to look for the cluster. If you destroy the
cluster using `terraform destroy` then you'll have to generate a new key for the next try.

Anyway the config will set up a master kubernetes droplet, and some addtional nodes. They
will nicely connect to the same etcd cluster, which will allow them to access each other.

Details
-------

TBD

