#!/bin/bash
set -xe
if $(cacli --status | jq '."logged-in"'); then
       echo You are logged in
else
       echo You need to login first
       exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER=`kubectl config current-context | sed "s/[\:\.\/,@]/-/g"`
NAMESPACE=guestbook
cacli cluster register --run -n $CLUSTER 
sleep 120
cacli k8s attach --namespace $NAMESPACE --cluster $CLUSTER
sleep 300
cacli sign --namespace $NAMESPACE --cluster $CLUSTER
