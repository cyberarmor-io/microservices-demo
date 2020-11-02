#!/bin/bash
set -x
cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c ${CA_CUSTOMER}

kubectl delete namespace dev prod cyberarmor-system || true
i="0"
namespaces=("prod" "dev" "cyberarmor-system")

while [ $i -lt 18 ] # wait up to three minutes for all namespace to stop running
do
  for (( ns=0; ns<${#namespaces[@]}; ns++ )); do
    pods=$(kubectl -n ${namespaces[$ns]} get pods 2>&1)
    if [ "$pods" = "No resources found." ]; then
      echo "namespaces ${namespaces[$ns]} not running"
      namespaces=( "${namespaces[@]:0:$ns}" "${namespaces[@]:$((ns + 1))}" ) # remove namespace from list
    fi
    if [ ${#namespaces[@]} -eq 0 ]; then
      i=18
      break
    fi
  done
  sleep 10
  i=$[$i+1]
done

echo "all namespace are not running, unregistering cluster"

np_result=`cacli np list  |grep HipsterShopCluster"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli np delete -n ` || true
echo "$np_result"
inp_result=`cacli inp list  |grep HipsterShopCluster"$DEMO_NUMBER" | sed s/\,//g | xargs -l1 cacli inp delete -n ` || true
echo "$inp_result"
cacli cluster unregister -n HipsterShopCluster"$DEMO_NUMBER"
