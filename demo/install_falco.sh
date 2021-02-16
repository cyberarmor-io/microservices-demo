#!/bin/bash
set -ex
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm install --set ebpf.enabled=false falco falcosecurity/falco
