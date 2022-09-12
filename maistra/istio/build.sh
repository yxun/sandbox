#!/bin/bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Pod initialization
oc new-project maistra-istio || true
oc apply -n maistra-istio -f ${DIR}/builder.yaml
POD=$(oc get pods -n maistra-istio -l job-name=example -o jsonpath={.items..metadata.name})
oc wait --for condition=Ready -n maistra-istio pod/${POD} --timeout 5m 
oc rsh -n maistra-istio pod/${POD} git clone \
    --single-branch --no-tags --depth=1 \
    -b maistra-2.2 \
    https://github.com/maistra/istio.git .

# Build and test
oc rsh -n maistra-istio pod/${POD} \
    make -e T=-v build racetest binaries-test

oc rsh -n maistra-istio pod/${POD} \
    make lint

oc rsh -n maistra-istio pod/${POD} \
    make gen-check
