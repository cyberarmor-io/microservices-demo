#!/bin/bash
set -xe
if $(cacli --status | jq '."logged-in"'); then
       echo You are logged in
else
       echo You need to login first
       exit 1
fi
CLUSTER=`kubectl config current-context | sed "s/[\:\.\/,@]/-/g"`
NAMESPACE=hipster

cacli np create --name $CLUSTER-basic-policy --policy_type basic --permissions deny --server_attributes cluster=$CLUSTER --client_attributes cluster=$CLUSTER --server_attributes namespace=$NAMESPACE --client_attributes namespace=$NAMESPACE
