#!/bin/bash
set -xe
if $(cacli --status | jq '."logged-in"'); then
       echo You are logged in
else
       echo You need to login first
       exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER=`kubectl config current-context | sed "s/[\.,@]/-/g"`
cacli cluster register --run -n $CLUSTER 
sleep 120
cacli secp create -sid sid://cluster-$CLUSTER/namespace-hipster/secret-ssl-private-key
cacli k8s attach --namespace hipster --cluster $CLUSTER 
sleep 300
cacli np create --name $CLUSTER-basic-policy --policy_type basic --server_attributes cluster=$CLUSTER --client_attributes cluster=$CLUSTER --server_attributes namespace=hipster --client_attributes namespace=hipster
cacli sign --namespace hipster --cluster $CLUSTER 

