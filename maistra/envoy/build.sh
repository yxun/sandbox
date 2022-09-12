#!/bin/bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Pod initialization
oc new-project envoy || true
oc apply -n envoy -f ${DIR}/builder.yaml
oc wait --for condition=Ready -n envoy pod/example --timeout 5m 
oc rsh -n envoy pod/example git clone \
    --single-branch --no-tags --depth=1 \
    -b maistra-2.2 \
    https://github.com/maistra/envoy.git .

# Build and test
oc rsh -n envoy pod/example ./maistra/run-ci.sh
