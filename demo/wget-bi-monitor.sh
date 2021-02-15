#!/bin/bash
set -xe
kubectl -n hipster exec -it $(kubectl -n hipster get pod | grep frontend |  awk '{print $1}') -- wget -qO-  http://bi-monitor:80