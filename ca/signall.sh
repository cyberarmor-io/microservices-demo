#!/bin/bash

NAMESPACE=dev
DEPLOYMENTS=`kubectl get deployment -n $NAMESPACE | tail -n +2  | awk '{print $1}'`

for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
  ./signone.sh "$DEPLOYMENT" &
done
