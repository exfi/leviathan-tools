#!/bin/bash

helm repo add external "$HELM_REPO" --username "$HELM_USER" --password "$HELM_PASS"
