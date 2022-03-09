#!/bin/bash

./bin/k3s kubectl apply -f deploy/kubernetes_manifests/dummy/deployment.yml
./bin/k3s kubectl apply -f deploy/kubernetes_manifests/dummy/service.yml
./bin/k3s kubectl apply -f deploy/kubernetes_manifests/dummy/ingress.yml
