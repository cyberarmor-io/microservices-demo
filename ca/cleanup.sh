#!/bin/bash
set -x
cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c ${CA_CUSTOMER}

kubectl delete namespace dev prod cyberarmor-system || true
#cacli np delete -n HipsterShop-Basic-Policy$DEMO_NUMBER || true
#cacli np delete -n HipsterShop-Cross-Namespace-Deny-Policy$DEMO_NUMBER || true
#cacli np delete -n HipsterShop-Block-Policy$DEMO_NUMBER || true
np_result=`cacli np list  |grep HipsterShop"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli np delete -n ` || true
echo "$np_result"
inp_result=`cacli inp list  |grep HipsterShop"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli inp delete -n ` || true
echo "$inp_result"
cacli wt list | python3 -c "import json,sys;d=json.load(sys.stdin);print('\n'.join(filter(lambda s: s.count('cluster-HipsterShopCluster$DEMO_NUMBER'),d)))" | xargs -L1 cacli cleanup -wlid "$@" || true
cacli cluster unregister -n HipsterShop"$DEMO_NUMBER"
