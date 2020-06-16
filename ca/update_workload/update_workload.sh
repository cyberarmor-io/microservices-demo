#!/bin/bash

kubectl apply -f update-redis-image.yaml -n prod || true
