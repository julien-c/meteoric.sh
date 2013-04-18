#!/bin/bash

# IP or URL of the server you want to deploy to
export APP_HOST=meteor.julien-c.fr

# Comment this if your host is not an EC2 instance
export EC2_PEM_FILE=~/.ssh/proxynet.pem

# What's your project's Git repo?
export GIT_URL=git://github.com/SachaG/Microscope.git

# Does your project use meteorite, or plain meteor?
export METEORITE=true

# What's your app name?
export APP_NAME=microscope


###################
# You usually don't need to change anything below this line
# 

export APP_DIR=/home/meteor
export ROOT_URL=http://$APP_HOST
export MONGO_URL=mongodb://localhost:27017/$APP_NAME

if $METEORITE; then
	export METEOR_CMD=mrt
	export METEOR_OPTIONS=''
else
	export METEOR_CMD=meteor
	export METEOR_OPTIONS='--release 0.6.2'
fi

if [ -z "$EC2_PEM_FILE" ]; then
	export SSH_HOST="root@$APP_HOST" SSH_OPT=""
else
	export SSH_HOST="ubuntu@$APP_HOST" SSH_OPT="-i $EC2_PEM_FILE"
fi



export SETUP="
sudo add-apt-repository ppa:chris-lea/node.js-legacy; 
sudo apt-get -qq update;
sudo apt-get install git mongodb;
sudo apt-get install nodejs npm;
node --version;
sudo npm install -g forever;
curl https://install.meteor.com | /bin/sh;
sudo npm install -g meteorite;
sudo mkdir -p $APP_DIR;
cd $APP_DIR;
pwd;
sudo git clone $GIT_URL $APP_NAME;
"

export DEPLOY="
cd $APP_DIR;
cd $APP_NAME;
sudo git pull;
sudo $METEOR_CMD bundle ../bundle.tgz $METEOR_OPTIONS;
cd ..;
sudo tar -zxvf bundle.tgz;
export MONGO_URL=$MONGO_URL;
export ROOT_URL=$ROOT_URL;
export PORT=80;
sudo forever start bundle/main.js;
"




case "$1" in
setup)
	ssh $SSH_OPT $SSH_HOST $SETUP
	;;
deploy)
	ssh $SSH_OPT $SSH_HOST $DEPLOY
	;;
*)
	cat <<ENDCAT
meteoric [action]

Available actions:

setup   - Install a meteor environment on a fresh Ubuntu server
deploy  - Deploy the app to the server
ENDCAT
	;;
esac
