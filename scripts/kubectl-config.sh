#!/bin/bash

# kubectl-config

kubectl config set-credentials default --token="$K8S_TOKEN"
kubectl config set-cluster default --server="$K8S_SERVER" --insecure-skip-tls-verify=true
kubectl config set-context default --cluster=default --user=default
kubectl config use-context default
