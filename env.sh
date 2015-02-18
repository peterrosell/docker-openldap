REGISTRY_HOST=registry.emendatus.com:5000
SERVICE_BASE_DIR=~/site/services

TAG=`git config --get remote.origin.url | sed 's/.*[\/:]\(.*\/.*\)/\1/'`
NAME=`echo $TAG | sed 's/.*\/.*-\(.?*\)/\1/'`
REGISTRY_TAG=$REGISTRY_HOST/$TAG
SERVICE_DIR=./service
#SERVICE_DIR=$SERVICE_BASE_DIR/$NAME
