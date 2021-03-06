Static multi host environment
=============================

In the next example we'll set up the same application, but spread accross muplit nodes.
We'll have one web node, one load balancer, two hosts for the backend,
and two for the database.

You can check what's goind to be run using `terraform plan`, and then apply the changes
using `terraform apply`. It will build the cluster from bottom to top, and finally return
some IPs we can connect to:

    Outputs:

    api_ipv4 = 178.62.126.185
    frontend_ipv4 = 178.62.127.36

    hosts =
    178.62.127.36 test-sztupy.hu
    178.62.126.185 api.test-sztupy.hu

These are publicly accessible IPs. You can slo run `terraform show` to display the rest
of the state of your cluster, including the IPs of the rest of the machines.

Once the cluster is up and running you can try playing with stopping machines, and checking
their impact. Log in to Digital Ocean's controller, and try stopping one of the backend hosts.
Checking the logs on the load balancer, you can see it will pick up the lack of host soon,
and stop routing to that address. Once you start the host again, you can see it accepting
connections again. You could connect to the `api` host, and follow the logs using
`journalctl -f`. Doing this you should be able to see HAProxy enabling and disabling the
connections as it sees the backends dying and starting up again.

You can do the same with one of the database boxes. You can even try stopping one,
adding some data to the other, starting the first one, then stopping the second, to
prove that the state is actually properly replicated accross.

Once you finished playing with the environment destroy it again using `terraform destroy`,
and continue with the [third step](../3)

Details
-------

Most of the contents here is very similar to the config in the previous step. The added
complexity is because we have now many nodes, and we have to tell them about each other.

You can find some hacks in `conf/api.conf` around the fact that you cannot supply arrays
as template variables inside template files, so we have to revert back to using comma
separated strings, and converting them to arrays inside the file:

      backend nodes
          balance roundrobin
          ${join("\n          ",formatlist("server %v %v:8080 check",split(",",backend_names),split(",",backend_urls)))}

We use similar tricks to the other nodes' configs, to make sure they are quite robust,
as afterwards we can just simply modify the `count` settings inside `main.tf` to change how
many nodes we want.

