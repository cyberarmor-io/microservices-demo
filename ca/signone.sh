#!/bin/bash
set -x

CLUSTER=HipsterShopCluster
NAMESPACE=dev
NAMESPACE_PROD=prod
DEPLOYMENT="$1"

wlid="wlid://cluster-$CLUSTER/namespace-$NAMESPACE/deployment-$DEPLOYMENT"
cacli sp delete -n signing-profile-$DEPLOYMENT &> /dev/null
container_name=`cacli wt get -wlid $wlid | python3 -c "import json,sys;print(json.load(sys.stdin)['containers'][0]['name'])"`

cacli sp generate -wlid $wlid -n $container_name -spn signing-profile-$DEPLOYMENT &> log.txt ||  (echo Failed to generate for "$DEPLOYMENT" && cat log.txt)

# patch_loadgenerator.py
if [ $DEPLOYMENT == "loadgenerator" ] ;then
  echo Patching loadgenerator
  tmpfile=$(mktemp /tmp/sp.XXXXXX)
  cacli sp get -n signing-profile-$DEPLOYMENT | python3 patch_loadgenerator.py > "$tmpfile"
  cacli sp delete -n signing-profile-$DEPLOYMENT
  cacli sp create -i "$tmpfile"
  rm "$tmpfile"
fi
wlid_prod="wlid://cluster-$CLUSTER/namespace-$NAMESPACE_PROD/deployment-$DEPLOYMENT"
tmpfile=$(mktemp /tmp/wt.XXXXXX)
cacli wt get -wlid $wlid | sed 's/dev/prod/g' > "$tmpfile"
cacli wt apply -i "$tmpfile"
rm "$tmpfile"
cacli sign -wlid $wlid_prod -c $container_name
      #cacli sign -wlid $wlid_prod -c $container_name &
#pids[${DEPLOYMENT}]=$!
echo Signed $DEPLOYMENT