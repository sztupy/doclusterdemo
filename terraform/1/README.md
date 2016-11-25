One host site
=============

The first example will show you how to use terraform to set up
the whole three-tiered app on a single host, to check if our application can actually boot.

First you should create a `terraform.tfvars` file, and fill in the details:

    access_key="<the token you have generated on the DO panel>"
    domain_name="<any random domain name, should be unique and not already used in digital ocean>"

Next you should run `terraform plan` which will return all of the changes it will do with
your account:

    + digitalocean_domain.default
        ip_address: "<computed>"
        name:       "<...>"

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
create a new droplet, where you'll have access to it using that key. It will also create
a new domain for you, and set it's A record to your new machine.

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

Once finished, continue with the [next step](../2), or you cn read more about the
details.

Details
-------

TBD

