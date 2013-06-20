# IP or URL of the server you want to deploy to
APP_HOST=meteor.julien-c.fr

# Comment this if your host is not an EC2 instance
EC2_PEM_FILE=~/.ssh/proxynet.pem

# What's your project's Git repo?
GIT_URL=git://github.com/SachaG/Microscope.git

# Does your project use meteorite, or plain meteor?
METEORITE=true

# If not using Meteorite, you need to specify this
METEOR_RELEASE=0.6.4

# What's your app name?
APP_NAME=microscope

# If your app is not on the project root, set this
APP_PATH=.

# If you would like to use a different branch, set it here
GIT_BRANCH=master

# Kill the forever and node processes, and deletes the bundle directory prior to deploying
FORCE_CLEAN=false
