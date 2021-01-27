#!/bin/bash
kubectl logs -f -l app=falco --max-log-requests=6
