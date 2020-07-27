#!/bin/bash
set -x

CLUSTER=HipsterShopCluster$DEMO_NUMBER
NAMESPACE=dev
NAMESPACE_PROD=prod
DEPLOYMENT="$1"
SP_NAME=signing-profile-$DEMO_NUMBER-$DEPLOYMENT

wlid="wlid://cluster-$CLUSTER/namespace-$NAMESPACE/deployment-$DEPLOYMENT"
cacli sp delete -n $SP_NAME &> /dev/null
container_name=`cacli wt get -wlid $wlid | python3 -c "import json,sys;print(json.load(sys.stdin)['containers'][0]['name'])"`
echo "wlid: $wlid, container_name: $container_name"
cacli sp generate -wlid $wlid -n $container_name -spn $SP_NAME &> log.txt ||  (echo Failed to generate for $DEPLOYMENT && cat log.txt)

# patch_loadgenerator.py
if [ $DEPLOYMENT == "loadgenerator" ] ;then
  echo Patching loadgenerator
  tmpfile=$(mktemp /tmp/sp.XXXXXX)
  cacli sp get -n $SP_NAME | python3 patch_loadgenerator.py > $tmpfile
  cacli sp delete -n $SP_NAME
  cacli sp create -i "$tmpfile"
  rm "$tmpfile"
fi
wlid_prod="wlid://cluster-$CLUSTER/namespace-$NAMESPACE_PROD/deployment-$DEPLOYMENT"
cacli wt update -wlid $wlid_prod -sp $SP_NAME
cacli sign -wlid $wlid_prod -c $container_name

#pids[${DEPLOYMENT}]=$!
echo "Signed $DEPLOYMENT, signing profile name: $SP_NAME"