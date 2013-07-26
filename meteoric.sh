#!/bin/bash

if [[ -n "$2" ]]; then
	source $2
else
	PWD=`pwd`
	source "$PWD/meteoric.config.sh"
fi

if [ -z "$GIT_URL" ]; then
	echo "You need to create a conf file named meteoric.config.sh"
	exit 1
fi

###################
# You usually don't need to change anything here –
# You should modify your meteoric.config.sh file instead.
#

APP_DIR=/home/meteor

if [ -z "$ROOT_URL" ]; then
    ROOT_URL=http://$APP_HOST
fi


if [ -z "$MONGO_URL" ]; then
	MONGO_URL=mongodb://localhost:27017/$APP_NAME
fi

if [ -z "$PORT" ]; then
    PORT=80
fi

if $METEORITE; then
	METEOR_CMD=mrt
	METEOR_OPTIONS=''
else
	METEOR_CMD=meteor
	if [ -z "METEOR_RELEASE" ]; then
		echo "When using meteor and not Meteorite, you have to specify $METEOR_RELEASE in the config file"
		exit 1
	fi
	METEOR_OPTIONS="--release $METEOR_RELEASE"
fi

if [ -z "$EC2_PEM_FILE" ]; then
	SSH_HOST="root@$APP_HOST" SSH_OPT=""
else
	SSH_HOST="ubuntu@$APP_HOST" SSH_OPT="-i $EC2_PEM_FILE"
fi



SETUP="
sudo apt-get install software-properties-common;
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

if [ -z "$APP_PATH" ]; then
	APP_PATH="."
fi


if [ -z "$GIT_BRANCH" ]; then
	GIT_BRANCH="master"
fi

DEPLOY="
cd $APP_DIR;
cd $APP_NAME;
echo Updating codebase;
sudo git fetch origin;
sudo git checkout $GIT_BRANCH;
sudo git pull;
cd $APP_PATH;
if [ "$FORCE_CLEAN" == "true" ]; then
    echo Killing forever and node;
    sudo killall nodejs;
    echo Cleaning bundle files;
    sudo rm -rf ../bundle > /dev/null 2>&1;
    sudo rm -rf ../bundle.tgz > /dev/null 2>&1;
fi;
echo Creating new bundle. This may take a few minutes;
sudo $METEOR_CMD bundle ../bundle.tgz $METEOR_OPTIONS;
cd ..;
sudo tar -zxvf bundle.tgz;
export MONGO_URL=$MONGO_URL;
export ROOT_URL=$ROOT_URL;
if [ -n "$MAIL_URL" ]; then
    export MAIL_URL=$MAIL_URL;
fi;
export PORT=$PORT;
"

if [ -n "$PRE_METEOR_START" ]; then
    DEPLOY="$DEPLOY $PRE_METEOR_START"
fi;

DEPLOY="$DEPLOY
echo Starting forever;
sudo -E forever restart bundle/main.js || forever start bundle/main.js;
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

