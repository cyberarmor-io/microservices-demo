#!/bin/bash

cacli cleanup -wlid wlid://cluster-HipsterShopCluster/namespace-prod/deployment-redis-cart || true
kubectl apply -f update-redis-image.yaml -n prod || true
