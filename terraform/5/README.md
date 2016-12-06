Add global logging
==================

While we could already check the logs manually, it would be good to have centralised logging. Fortunately
that's quite simple, as kubernetes already set up docker's logging in a nice way. We just need to add some
containers that would collect these logs and ship them to a logging service. The ELK stack is a fairly common
and open source way of handling logs globally, and we'll be doing that.

Once you go to the 5th directory, simply run `initializeLogging.sh`. The command will obtain the IPs from
terraform, then first install the fluentd logger to the nodes, and finally install it, and the rest of the ELK
stack to master.

Unfortunately the code still runs inside kubernetes' private network, not accessible from outside. One option we
could do is expose them using a separate ingress controller, similar to how it was done with the frontend and
backend services.

As these are admin endpoints however, we might get away with having some user-friendliness, and we'll just simply
access them by port forwarding the master node's internal network to our computer.

If you run now `adminProxy.sh`, it will return a list of endpoints to try, including Kibana and the Kubernetes Dashboard.
Try opening them up inside the browser:

* Kibana: http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kibana-logging/
* Kubernetes Dashboard: http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/

Once done, if you want to save money, you should go back to the 3rd directory and actually get rid of your cloud.
You should be able to recreate it in a few minutes anytime you need it anyway!

    terraform destroy

When asked for the etcd url just type in any value. You won't need the proper value to decomission the services.

Details
-------

The logging is done by using the fact that everything runs in docker containers, and all of the standard out
from docker goes to `/var/log/docker`. Kubernetes itself makes sure that the logs there have a nice format as well,
which allows log collectors, like fluentd to properly annotate them before sending them to elasticsearch.

The ELK stack shown here is a standard addon from kubernetes, however the kibana app has some issues as it's base path
is not set up properly for accessing it via the admin URLs. Therefore alternatively a different kibana is used
from https://hub.docker.com/r/ntfrnzn/kibana-kubernetes-proxy/ .

One improvement to do here would be to make sure these services have their own load balancer in front of them, making
these endpoints accessible from the outside. In this case however care should be taken to add proper authentication
as well!

