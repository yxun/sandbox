#!/bin/bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Pod initialization
oc new-project isito-ci || true
oc apply -n istio-ci -f ${DIR}/builder.yaml
oc wait --for condition=Ready -n istio-ci pod/example --timeout 5m 
oc rsh -n istio-ci pod/example git clone \
    --single-branch --no-tags --depth=1 \
    -b release-1.14 \
    https://github.com/istio/istio.git .

# Build and test
## go mod vendor
##oc adm policy add-scc-to-user anyuid -z default --as system:admin
##oc adm policy add-scc-to-user anyuid -z deployer --as system:admin
##oc adm policy add-scc-to-user anyuid -z istio-eastwestgateway-service-account --as system:admin
##oc adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account --as system:admin
##oc adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account --as system:admin
##oc adm policy add-scc-to-user anyuid -z istio-reader-service-account --as system:admin
##oc adm policy add-scc-to-user anyuid -z istiod-canary --as system:admin
##oc adm policy add-scc-to-user anyuid -z istiod-service-account --as system:admin
##oc adm policy add-scc-to-user anyuid -z istiod-stable --as system:admin

HUB="docker.io/istio" TAG="1.14.0" go test -v -tags=integ ./tests/integration/pilot/... -p 1 --istio.test.kube.config=~/.kube/config
