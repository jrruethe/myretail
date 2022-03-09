#!/bin/bash

# Run this in its own terminal

# k3s requires root :(
sudo ./bin/k3s server --config $(pwd)/config/k3s.yml

# The kubeconfig file is written to /etc/rancher/k3s/k3s.yaml
