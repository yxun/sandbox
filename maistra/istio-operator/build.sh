#!/bin/bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Pod initialization
oc new-project istio-operator || true
oc apply -n istio-operator -f ${DIR}/builder.yaml
POD=$(oc get pods -n istio-operator -l job-name=example -o jsonpath={.items..metadata.name})
oc wait --for condition=Ready -n istio-operator pod/${POD} --timeout 5m 
oc rsh -n istio-operator pod/${POD} git clone \
    --single-branch --no-tags --depth=1 \
    -b maistra-2.2 \
    https://github.com/maistra/istio-operator.git .

# Build and test
oc rsh -n istio-operator pod/${POD} \
    make compile test

oc rsh -n istio-operator pod/${POD} \
    make gen-check

oc rsh -n istio-operator pod/${POD} \
    make lint