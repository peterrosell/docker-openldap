#!/bin/bash
SCRIPT_PATH=$(dirname `which $0`)
source $SCRIPT_PATH/env.sh

CMD="docker run \
	-d \
	--name $NAME \
	$@ \
	-v /site/data/$NAME:/ext/data \
	-v /site/etc/$NAME:/ext/etc \
	-v /site/log/$NAME:/ext/log \
	-t $TAG"
echo $CMD

$CMD
