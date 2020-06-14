#!/bin/bash
CLUSTER=HipsterShopCluster
NAMESPACE=dev
NAMESPACE_PROD=prod
DEPLOYMENTS=`kubectl get deployment -n $NAMESPACE | tail -n +2  | awk '{print $1}'`

for DEPLOYMENT in $DEPLOYMENTS
do
	        wlid="wlid://cluster-$CLUSTER/namespace-$NAMESPACE/deployment-$DEPLOYMENT"
	        cacli sp delete -n signing-profile-$DEPLOYMENT &> /dev/null
	        container_name=`cacli wt get -wlid $wlid | python -c "import json,sys;print json.load(sys.stdin)['containers'][0]['name']"`
	        cacli sp generate -wlid $wlid -n $container_name -spn signing-profile-$DEPLOYMENT &> log.txt || (echo Failed to generate for $DEPLOYMENT && cat log.txt)
# patch_loadgenerator.py
		if [ $DEPLOYMENT == "loadgenerator" ] ;then
                        echo Patching loadgenerator
                        cacli sp get -n signing-profile-$DEPLOYMENT | python3 ca/patch_loadgenerator.py > sp.json
			cat sp.json
			cacli sp delete -n signing-profile-$DEPLOYMENT
                        cacli sp create -i sp.json
                fi
		wlid_prod="wlid://cluster-$CLUSTER/namespace-$NAMESPACE_PROD/deployment-$DEPLOYMENT"
	        cacli wt get -wlid $wlid | sed 's/dev/prod/g' > tmp.json
	        cacli wt apply -i tmp.json
		cat tmp.json
	        cacli sign -wlid $wlid_prod -c $container_name
	        echo Signed $DEPLOYMENT
done

