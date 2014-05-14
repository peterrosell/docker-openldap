#!/bin/bash
SCRIPT_PATH=$(dirname `which $0`)
echo $SCRIPT_PATH
source $SCRIPT_PATH/env.sh
echo $TAG -- $NAME
docker run \
	--name $NAME \
	-v /site/data/$NAME:/ext/data \
	-v /site/etc/$NAME:/ext/etc \
	-v /site/log/$NAME:/ext/log \
	-i \
	-t $TAG \
	/bin/bash
