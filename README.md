# Meteoric

Deploy Meteor on EC2 (or your own server)

## How to install and update

The easiest way to install (or update) `meteoric` is using curl:

```bash
$ curl https://raw.github.com/julien-c/meteoric.sh/master/install | sh
```

You may need to `sudo` in order for the script to symlink `meteoric` to your `/usr/local/bin`.

## How to use

Create a conf file named `meteoric.config.sh` in your project's folder, setting the following environment variables:

```bash
# IP or URL of the server you want to deploy to
APP_HOST=example.com

# Comment this if your host is not an EC2 instance
EC2_PEM_FILE=~/.ssh/your-aws-certif.pem

# What's your project's Git repo?
GIT_URL=git://github.com/SachaG/Microscope.git

# Does your project use meteorite, or plain meteor?
METEORITE=true

# What's your app name?
APP_NAME=microscope
```

Then just run:

```bash
$ meteoric setup

$ meteoric deploy
```

## Inspiration

Hat tip to @netmute for his [meteor.sh script](https://github.com/netmute/meteor.sh). In our case though, we think having to rebuild native packages like `fibers` kind of defeats the whole point of bundling the Meteor app. Additionally, our approach enables hot code fixes (you don't have to stop/start your node server, and your users' apps shouldn't be disrupted).

This script is also based on this previous post: [How to deploy Meteor on Amazon EC2](http://julien-c.fr/2012/10/meteor-amazon-ec2/).

Cheers!
