#!/bin/bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Pod initialization
oc new-project proxy || true
oc apply -n proxy -f ${DIR}/builder.yaml
oc wait --for condition=Ready -n proxy pod/example --timeout 5m 
oc rsh -n proxy pod/example git clone \
    --single-branch --no-tags --depth=1 \
    -b maistra-2.2 \
    https://github.com/maistra/proxy.git .

# Build and test
oc rsh -n proxy pod/example ./maistra/ci/pre-submit.sh
