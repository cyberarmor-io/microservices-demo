#!/bin/bash
set -xe
if $(cacli --status | jq '."logged-in"'); then
       echo You are logged in
else
       echo You need to login first
       exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER=`kubectl config current-context | sed "s/[\:\.\/,@,_]/-/g"`
#CLUSTER=gkedemo
NAMESPACE=hipster
cacli cluster register --run -n $CLUSTER 
sleep 120
cacli secp create -sid sid://cluster-$CLUSTER/namespace-$NAMESPACE/secret-ssl-private-key
cacli k8s attach --namespace $NAMESPACE --cluster $CLUSTER
sleep 300
#cacli np create --name $CLUSTER-basic-policy --policy_type basic --server_attributes cluster=$CLUSTER --client_attributes cluster=$CLUSTER --server_attributes namespace=$NAMESPACE --client_attributes namespace=$NAMESPACE
cacli sign --namespace $NAMESPACE --cluster $CLUSTER

