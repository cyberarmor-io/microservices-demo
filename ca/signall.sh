#!/bin/bash
set -x

cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c ${CA_CUSTOMER}

NAMESPACE=dev
DEPLOYMENTS=`kubectl get deployment -n $NAMESPACE | tail -n +2  | awk '{print $1}'`

for DEPLOYMENT in $DEPLOYMENTS; do
  ./signone.sh $DEPLOYMENT &
  sleep 1
done

