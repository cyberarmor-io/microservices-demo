#!/bin/bash
set -x

CLUSTER=HipsterShopCluster$DEMO_NUMBER
NAMESPACE=dev
NAMESPACE_PROD=prod
DEPLOYMENT="$1"
SP_NAME=signing-profile-$DEMO_NUMBER-$DEPLOYMENT

# generate sp in dev
wlid="wlid://cluster-$CLUSTER/namespace-$NAMESPACE/deployment-$DEPLOYMENT"
cacli sp delete -n $SP_NAME &> /dev/null
cacli sp generate -wlid $wlid -spn $SP_NAME &> log.txt ||  (echo Failed to generate for $DEPLOYMENT && cat log.txt)

# patch_loadgenerator.py
if [ $DEPLOYMENT == "loadgenerator" ] ;then
  echo Patching loadgenerator
  tmpfile=$(mktemp /tmp/sp.XXXXXX)
  cacli sp get -n $SP_NAME | python3 patch_loadgenerator.py > $tmpfile
  cacli sp delete -n $SP_NAME
  cacli sp create -i "$tmpfile"
  rm "$tmpfile"
fi

# update prod sp
wlid_prod="wlid://cluster-$CLUSTER/namespace-$NAMESPACE_PROD/deployment-$DEPLOYMENT"
cacli wt update -wlid $wlid_prod --signing-profile $SP_NAME
cacli wt sign -wlid $wlid_prod

#pids[${DEPLOYMENT}]=$!
echo "Signed $DEPLOYMENT, signing profile name: $SP_NAME"