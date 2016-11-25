Digital Ocean docker cluster demo
=================================

The aim of this project is to supply some example configurations on how to set up
a complete HA cluster of a simple three-tiered application on [Digital Ocean][3].

Digital Ocean was chosen because it is a quite bare-metal approach, and lacks a lot
of functionality of bigger cloud providers, like AWS, GCE or Azure. Mot of the steps
described here can however be used on other providers, but not that some functionality,
like virtual networking or load balancing have a much better support on them, and
you might opt to use them, instead of the bare-metal approach. However sometimes it
is good to know things interact with each other to get a better sense of what's
happening in the background. Also knowing how to solve the shortcomings of a bare-metal
approach can help you in not getting vendor locked in with a specific provider.

The demo application is a slightly modified version of [Todo Backend][1], with support
for [Cassandra][2] as a database layer. You can find these modifications inside the various
directories:

* `frontend`: This is Todo Backend's frontend, modified so it is served from a docker
  container,  and you can set the API url from an environmental variable during boot
* `backend`: This contains the Dropwizard backend, slightly modified to use Cassandra as
  the database layer instead of an in memory store
* `api`: This contains HAProxy with an rsyslog changes that will make sure the output is
  logged to stdout, for better docker logging compatibility

Prerequisities
==============

The steps to deploy the cluster is done in stages, you can find them inside the `terraform`
directory.

To run them you'll need the following:

* Register to Digital Ocean. You can [use this referral link][4] to get $10 free credit
  once you sign up. Finishing the demos should not cost you more than $2 (unless you want
  to keep the services running and don't shut them down). You will need to add either a
  credit/debit card or a PayPal account before you have access of creating new droplets.

* Install [terraform][5]. You can either download the binary, or you can use the following
  package managers:

    * [homebrew][6] on Mac OS X: `brew install terraform`
    * [chocolatey][7] on Windows: `choco install terraform`

* Install [git][8] if you don't have it, then clone this repository to your local machine:

    * `git clone https://github.com/sztupy/doclusterdemo.git`

* Make sure you have `ssh` and `scp` working. On Windows you can use git's bash prompt.
  Also make sure you have an [SSH public key][9], and it is accessible at
  `~/.ssh/id_rsa.pub`

* Generate a [new access token][10] on Digital Ocean, and write the code down.

Once you have them up and running, continue with the [first step][11]

[1]: http://www.todobackend.com/
[2]: http://cassandra.apache.org/
[3]: https://www.digitalocean.com/
[4]: https://m.do.co/c/5b7b04063796
[5]: https://www.terraform.io/intro/getting-started/install.html
[6]: http://brew.sh/
[7]: https://chocolatey.org/
[8]: https://git-scm.com/downloads
[9]: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
[10]: https://cloud.digitalocean.com/settings/api/tokens
[11]: terraform/1
