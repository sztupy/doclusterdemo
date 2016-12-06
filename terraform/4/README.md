Application running on Kubernetes
=================================

After the kubernetes cluster is set up we'd need to set up our application. We won't use the main terraform
command here, as we already have our cluster set up. However, terraform can still help us in determining
some values (IP addresses) from our created machines.

In short, go the the 4th directory and run `initializeCluster.sh`. The command will obtain the IPs from
terraform, then first copy over the kubernetes configuration files, and run them on the box. As we don't have
a domain name set up and we need to use the IPs, it will also change some of the config files, so it would contain
the proper IP.

Once the command has been run, you can connect to the box and check the status of kubernetes. Some commands you might
want to try out:

    ssh core@<master_ip>
    sudo su
    
    # list all of the pods on the cluster
    /opt/bin/kubectl get pods
    
    # get some information about the pods
    /opt/bin/kubectl describe pods
    
    # get some information about the nodes
    /opt/bin/kubectl describe nodes
    
    # check logs from a pod
    /opt/bin/kubectl logs <enter_pod_name>
    
    # enter into a pod to play around
    /opt/bin/kubectl exec -ti <enter_pod_name> bash

Next we'll add some logging. Go to the [fifth step](../5)

Note: if you want to decomission your environment, just run `./clearCluster.sh`, which should remove everything
from your default kubernetes namespace (note: this includes things that were possibly set up separately)

Details
-------

Kubernetes provides a high level of abstraction on your infrastructure. Instead of deciding what to deploy and where
you just specify what you want to have, and kubernetes will take care of the rest.

In the examples we have three different ways of deploying services:

* Cassandra is deployed using `PetSet`. PetSets are a new concept in kubernetes. They abstract away sets of services,
  which usually need to have some permanent store, and which need to communicate to each other. Usually these services
  are the data layer, as the various nodes need to communicate each other to replicate the information across. Cassandra
  was one of the databases [that was used to test if PetSets work](http://blog.kubernetes.io/2016/07/thousand-instances-of-cassandra-using-kubernetes-pet-set.html)
  in kubernetes.

* The frontend and backend services are deployed using the `Deployment` controller. Deployments abstract away updates
  for services, which run independently to each other, and you usually only have multiples of them for load balancing and high
  availability. Web servers serving static contents, and backend stateless microservices are good examples of what
  you can deploy using the `Deployment` controller. One additional function of the controller is, that it allows rolling
  updates of the underlying pods, meaning if you have a newer version to deploy, you can specify the new version,
  and kubernetes will take care of updating the pods one-by-one.

* Finally the load balancer is deployed using `ReplicationControllers`. This is very similar to the `Deployment` one,
  but doesn't support rolling updates natively. As the load balancer is more static in our environment this should
  be okay.

  For the load balancer we also have some additional config. First we mark one of our nodes using a label, and then tell
  the replication controller, that it can only deploy the load balancer to this particular node. This way we can make sure
  we know where the load balancer ends up. While this is usually not needed for the rest of the pods, this is a quite
  useful feature to have for the load balancer.

* Finally we are also using a new feature called `Ingress`, which is essentially a way to configure our load balancer from
  kubernetes. This way instead of us adding special configs inside the load balancer, we just specify what services we have,
  and we let kubernetes take care of creating the proper routings inside the load balancer. Currently kubernetes supports
  a specially crafted nginx for this purpose.
