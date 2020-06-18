#!/bin/bash
set -x
NAMESPACE=dev
DEPLOYMENTS=`kubectl get deployment -n $NAMESPACE | tail -n +2  | awk '{print $1}'`

for DEPLOYMENT in $DEPLOYMENTS; do
  ./signone.sh $DEPLOYMENT &
  sleep 1
done

#CLUSTER=HipsterShopCluster
#NAMESPACE=dev
#NAMESPACE_PROD=prod
#DEPLOYMENTS=`kubectl get deployment -n $NAMESPACE | tail -n +2  | awk '{print $1}'`
#
#for DEPLOYMENT in $DEPLOYMENTS
#do
#    wlid="wlid://cluster-$CLUSTER/namespace-$NAMESPACE/deployment-$DEPLOYMENT"
#    cacli sp delete -n signing-profile-$DEPLOYMENT &> /dev/null
#    container_name=`cacli wt get -wlid $wlid | python -c "import json,sys;print json.load(sys.stdin)['containers'][0]['name']"`
#    for _ in {1..5}; do
#        cacli sp generate -wlid $wlid -n $container_name -spn signing-profile-$DEPLOYMENT &> log.txt
#        RESULT=$?
#        if [ "$RESULT" -eq 0 ]; then
#            break
#        else
#            echo Failed to generate for "$DEPLOYMENT" && cat log.txt
#            sleep 30
#        fi
#    done
#		if [ $DEPLOYMENT == "loadgenerator" ] ;then
#        echo Patching loadgenerator
#        tmpfile=$(mktemp /tmp/sp.XXXXXX)
#        cacli sp get -n signing-profile-$DEPLOYMENT | python3 ca/patch_loadgenerator.py > "$tmpfile"
#        cacli sp delete -n signing-profile-$DEPLOYMENT
#        cacli sp create -i "$tmpfile"
#        rm "$tmpfile"
#    fi
#		wlid_prod="wlid://cluster-$CLUSTER/namespace-$NAMESPACE_PROD/deployment-$DEPLOYMENT"
#		tmpfile=$(mktemp /tmp/wt.XXXXXX)
#    cacli wt get -wlid $wlid | sed 's/dev/prod/g' > "$tmpfile"
#    cacli wt apply -i "$tmpfile"
#		rm "$tmpfile"
#    cacli sign -wlid $wlid_prod -c $container_name
#    echo Signed $DEPLOYMENT
#done


#for pid in ${pids[*]}; do
#    wait $pid
#    echo Done $pid
#done


