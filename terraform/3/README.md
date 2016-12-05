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
will nicely connect to the same etcd cluster, which will allow them to access each other,
the configs will also nicely set up kubernetes on each of the nodes as well.

Note: it is possible that during setting up the master node, your droplet is moved to
a host which has a lot of "noisy neighbours", and download speed is a bit slow. This
can result in cloud-init to timeout while downloading kubelet-wrapper. In this case,
just destroy the whole cluster and re-try, as your droplets will be moved to a different
host.

In this step we just provision the environment, to set up the application please see
the [fourth step](../4)


Details
-------

Most of the master and slave node's config follow the steps described on CoreOS's
[kubernetes setup guide](https://github.com/coreos/coreos-kubernetes/blob/v0.8.3/Documentation/getting-started.md)

Some notes on the setup:

* The keys are generated during node startup using a `oneshot` type systemd service
* For security `etcd2` is set up to use SSL. For ease of setup it uses the same keys as kubernetes
* Kubernetes, flannel and related services are all set up as `systemd` modules inside the cloud-init config
* There is a second `oneshot` service that will bootstrap kubernetes once the kube-api container is up
* The rest of the config is essentally the

Some notes on what happens during initialization:

* First we generate the SSL keys.

* Once that's done we can start up etcd2

* As etcd2 boots and initializes, we start up flannel. Flannel is a virtual network layer, that will help
  our infrastructure to have a "flat" IP range, instead of the usual random IP addresses we get from
  Digital Ocean

* One of the more fun parts of flannel is that it is run as a container. However docker needs to have the
  networking set up before it can be started up. To solve the chicken and egg problem, in CoreOS flannel
  is run as a rocket container, which is already started, hence containers can be run before docker.

* Once flannel and docker is initialized, kubernetes is started up. As usual inside CoreOS, kubelet doesn't
  run as a binary but as a rocket container. If you check the logs during bootstrap (`journalctl -f`) you can
  actually see it downloading the image and starting up:

        Dec 05 21:37:47 master kubelet-wrapper[1903]: Downloading ACI:  78.7 MB/237 MB
        Dec 05 21:37:48 master kubelet-wrapper[1903]: Downloading ACI:  86.3 MB/237 MB
        Dec 05 21:37:49 master kubelet-wrapper[1903]: Downloading ACI:  94.3 MB/237 MB

* After kubelet is starting it will download and start some of it's internal containers, like the API server.
  Note that kubelet doesn't really know it doesn't yet have an API server and will constantly trying to connect
  to the non-existing API server, for example to tell it that the API server is still downloading. You can see
  quite a lot of errors in the logs hence:

        Dec 05 21:39:08 master kubelet-wrapper[1903]: E1205 21:39:08.930677    1903 reflector.go:203] pkg/kubelet/kubelet.go:403: Failed to list *api.Node: Get http://127.0.0.1:8080/api/v1/nodes?fieldSelector=metadata.name%3D10.131.35.43&resourceVersion=0: dial tcp 127.0.0.1:8080: getsockopt: connection refused

* After a while however the API is downloaded and started by kubernetes (you can try doing a `docker ps` to see
  it up and running). Once this happens the errors go away, as now kubelet can connect to the API server. Also
  note that a secondary bootstrap mechanism will download `kubectl`, and use it to install some kubernetes modules
  (the dashboard and the kube-dns provider).

* If everything is in order you'll be able to see the following line, signalling that cloud-init has succeeded in
  finishing the tasks described in the config:

        Dec 05 21:41:18 master systemd[1]: Reached target Multi-User System.


There are some improvement possibilities here:

* The optional calico plugin is not enabled, to make booting times smaller. Also there is an
  [outstanding bug](https://github.com/coreos/coreos-kubernetes/issues/754) with coreos, calico and etcd using
  SSL certificates, that needs to be worked around for this to work
* Also for security the CA for etcd and kubernetes should be different
* Also inside etcd there should be proper roles set up for the supplied keys, so everyone would only access to
  the data it needs to
* While setting up everything from `cloud-init` is nice, it means that the settings will be re-provisioned on
  every boot. It might be better to get the data on the first startup from a different place, including terraform
  provisioners, a git repository, etc.
* The IP of the master node is sent over to the slave nodes using terraform. As etcd is already set up it could
  be used instead.
* We only have one master node, and etcd is running in single-master mode as well. It would be good to add HA to
  the master nodes as well.


