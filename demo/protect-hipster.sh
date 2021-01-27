#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER=`kubectl config current-context`
cacli cluster register --run -n $CLUSTER 
sleep 120
cacli secret encrypt -sid sid://cluster-$CLUSTER/namespace-hipster/secret-top-secret
cacli k8s attach --namespace hipster -cluster $CLUSTER 
sleep 300
cacli sign --namespace hipster -cluster $CLUSTER 

