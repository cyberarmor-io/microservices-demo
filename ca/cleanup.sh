#!/bin/bash
set -x
cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c ${CA_CUSTOMER}

kubectl delete namespace dev prod cyberarmor-system || true
sleep 20
#cacli np delete -n HipsterShop-Basic-Policy$DEMO_NUMBER || true
#cacli np delete -n HipsterShop-Cross-Namespace-Deny-Policy$DEMO_NUMBER || true
#cacli np delete -n HipsterShop-Block-Policy$DEMO_NUMBER || true
np_result=`cacli np list  |grep HipsterShopCluster"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli np delete -n ` || true
echo "$np_result"
inp_result=`cacli inp list  |grep HipsterShopCluster"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli inp delete -n ` || true
echo "$inp_result"
cacli cluster unregister -n HipsterShopCluster"$DEMO_NUMBER"
