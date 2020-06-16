#!/bin/bash
kubectl set image deployment/redis-cart -n prod redis=redis:5-alpine
