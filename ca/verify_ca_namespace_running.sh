#!/bin/bash

# PLEASE DON'T CHANGE THE FILE
while true; do
    i=$(($i + 1))
    status=$(kubectl -n cyberarmor-system get pod --no-headers |  awk '{print $3}' )
    if [ ! $status = "No resources found." ]; then
        echo "No resources found."
        continue
    fi
    echo "found!!!!!!!!!"
    for pod in $status; do
        if [ ! -z ${pod} ] && [ ${pod} = "Running" ]; then
            break
        fi

    if [ $i -eq 18 ]; then
        echo "$pod not running after 3 minutes"
        exit 1
    fi
sleep 10
done

status=$(kubectl -n cyberarmor-syssstem get pod --no-headers |  awk '{print $3}' )
for i in $status; do
    echo $i
done
# echo $status