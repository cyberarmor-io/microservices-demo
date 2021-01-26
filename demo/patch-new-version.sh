#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
kubectl -n hipster patch deployment frontend --patch "$(cat $DIR/patch.yaml)"
