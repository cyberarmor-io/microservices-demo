#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER=`kubectl config current-context`
kubectl delete ns hipster cyberarmor-system
sleep 120
cacli cluster unregister -n $CLUSTER 
sleep 120

