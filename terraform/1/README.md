One host site
=============

The first example will show you how to use terraform to set up
the whole three-tiered app on a single host, to check if our application can actually boot.

First you should create a `terraform.tfvars` file, and fill in the details:

    access_key="<the token you have generated on the DO panel>"

Next you should run `terraform plan` which will return all of the changes it will do with
your account:

    + digitalocean_droplet.web
        disk:                 "<computed>"
        image:                "coreos-stable"
        ipv4_address:         "<computed>"
        ipv4_address_private: "<computed>"
        ipv6_address:         "<computed>"
        ipv6_address_private: "<computed>"
        locked:               "<computed>"
        name:                 "web"
        private_networking:   "true"
        region:               "lon1"
        resize_disk:          "true"
        size:                 "2gb"
        ssh_keys.#:           "<computed>"
        status:               "<computed>"
        user_data:            "<...>"
        vcpus:                "<computed>"

    + digitalocean_ssh_key.dodemo
        fingerprint: "<computed>"
        name:        "DO Demo Key"
        public_key:  "<...>"

This tells us that terraform will upload your public key to digital ocean, so it can
create a new droplet, where you'll have access to it using that key.

If you're happy with the changes you can apply it using `terraform apply`.

It should do the steps outlined in the plan, and once it is finished should tell you
the IP address of the machine it created:

    Outputs:

    hosts =
    46.101.2.150 test-sztupy.hu

    main_ipv4 = 46.101.2.150

To connect to the machine, you can either use the IP, or you can append the hosts
output to your `/etc/hosts` file (`C:\Windows\System32\Drivers\etc\hosts` onw Windows):

    $ ssh core@46.101.2.150

Once connected you can check the system logs using `journalctl -f`. Once you see that
the serivces are up and running you should also be able to connect to the site on your
browser, by etnering the IP address.

Once finished, you can decomission your servers using `terraform destroy`. To check
what it will do simply use `terraform plan --destroy`.

Once finished, continue with the [next step](../2), or you can read more about the
details.

Details
-------

Here we are only using one terraform file, called `main.tf`. While you can, and
should modularize your configurations across files, for our current example it
should be enough.

At the start we define what variables we require (the digital ocean access key),
then we set up the digital ocean provider to use that key.

We then install your SSH key into digital ocean. As usually SSH public keys live
in `~/.ssh/id_rsa.pub` we can just hard code this value here. Alterntively we could
have made this a variable as well, and just default it to this value if we
want more control.

Afterwards comes the main part, where we create a new node. Most of it should be
self-explanatory, but I added some comments:

    resource "digitalocean_droplet" "web" {
      image              = "coreos-stable" # the image to use. You can try out the beta and alpha channel as well if you like to live on the edge
      name               = "web"           # the name of the node to create.
      region             = "lon1"          # the region to put this new node. lon1 is the main London datacenter
      size               = "2gb"           # the amount of RAM you want to give the node
      private_networking = true            # whether we need a datacenter-internal IP or not. It's usually good to have if you want to create a cluster
      ssh_keys           = ["${digitalocean_ssh_key.dodemo.id}"]   # The SSH key to inject into our new node.
                               # Here we just refer to the ID of the previously created resource. Note that CoreOS on DO always requires access by SSH keys,
                               # you cannot set up password auth for root at droplet creation.
      user_data          = "${file("web.conf")}"  # the cloud-config file to set up the node
    }

The most important part here is the `user_data` where you can specify a `cloud-init` compatible file.
We'll come back to this point later.

At the end of the terraform file comes the outputs. These are essentially output variables,
which we deem important. We output the public IP of the box we created as both a separate
value, and as an output that you could potentially use to update your hosts file.

Now let's check the `web.conf`. Here is an annotated version of it's contents:

    #cloud-config
    # cloud config MUST start with the line above, otherwise provisioning will fail.
    # If you use any kind of YAML editor make sure it keeps the above line inside the output file
    coreos:
      units: # here we can create new systemd compatible services. Some are already provided (like etcd2),
             # and we just tell CoreOS to start them up, but some of them we create completely in this section
        - name: "etcd2.service"
          command: "start"
        - name: "docker-frontend.service" # for example this is how you could start up a docker container using only systemd units
          command: "start"
          content: |
            [Unit]
            Description=Frontend Service
            Author=Me
            After=docker.service

            [Service]
            Restart=always
            ExecStartPre=-/usr/bin/docker kill frontend   # =- means we don't care if the command fails. As these commands are for cleanup only this should be okay
            ExecStartPre=-/usr/bin/docker rm frontend
            ExecStartPre=/usr/bin/docker pull doclusterdemo/frontend
            ExecStart=/usr/bin/docker run -p 80:80 -e API_ROOT_URL=http://$public_ipv4:8080/todo --name frontend doclusterdemo/frontend
                # we could have used some other configuration mechanism here as well,
                # but as this is a simple service providing everything on the command line should be enough
            ExecStop=/usr/bin/docker stop frontend
        - name: "docker-backend.service"
          # you can have many other services as well
          # (...)
