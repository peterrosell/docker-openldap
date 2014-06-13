#!/bin/bash
SCRIPT_PATH=$(dirname `which $0`)
source $SCRIPT_PATH/env.sh
docker build  $@ -t $TAG .
if [ -n "$REGISTRY_TAG" ]; then
	docker tag $TAG $REGISTRY_TAG
	docker push $REGISTRY_TAG
fi

fig2coreos $NAME fig.yml $SERVICE_DIR
