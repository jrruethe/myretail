#!/bin/bash

# Run this in its own terminal

# k3s requires root :(
# Note that the metrics server is disabled due to this issue:
# https://github.com/k3s-io/k3s/issues/5133
# https://github.com/kubernetes/kubernetes/issues/108364
sudo ./bin/k3s server \
--config $(pwd)/config/k3s.yml \
--write-kubeconfig $(pwd)/config/kubeconfig.yml \
--private-registry $(pwd)/config/registries.yml \
--disable metrics-server

# The kubeconfig file is written to /etc/rancher/k3s/k3s.yaml
