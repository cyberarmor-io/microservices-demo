#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#CLUSTER=`kubectl -n cyberarmor-system exec -it $(kubectl get pod -n cyberarmor-system | grep ca-webhook |  awk '{print $1}') -- env | grep CA_CLUSTER_NAME | tr "=" " " | awk '{print $2}'`
CLUSTER=hipster-demo
kubectl delete ns hipster cyberarmor-system
sleep 120
cacli cluster unregister -n $CLUSTER 
sleep 120
