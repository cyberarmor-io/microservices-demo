#!/bin/bash
helm install --set ebpf.enabled=true falco falcosecurity/falco
