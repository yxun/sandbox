#!/bin/bash

set -ex

DIR="$(cd "$(dirname "$0")" && pwd)"

source "${DIR}/maistra_builder.env"

# Install all dependencies avaiable in RPM repos
# Stick with clang 14.0.6
# Stick with golang 1.19
function install_rpm_deps() {
    curl -sfL https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
    curl -sfL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
    dnf -y upgrade --refresh
    dnf -y install dnf-plugins-core
    dnf -y config-manager --set-enabled powertools
    dnf -y install epel-release epel-next-release
    dnf -y copr enable @maistra/istio-2.3 centos-stream-8-x86_64
    dnf -y module reset ruby nodejs python38 && dnf -y module enable ruby:2.7 nodejs:16 python38 && \
        dnf -y module install ruby nodejs python38
    dnf -y install --setopt=install_weak_deps=False \
        git make libtool patch which ninja-build go-toolset-0:1.19.4 xz redhat-rpm-config \
        autoconf automake libtool cmake python2 libstdc++-static \
        java-11-openjdk-devel jq file diffutils lbzip2 \
        ruby-devel zlib-devel openssl-devel python2-setuptools gcc-toolset-12-libatomic-devel \
        clang-0:14.0.6-1.module_el8.7.0+1198+0c3eb6e2 llvm-0:14.0.6-1.module_el8.7.0+1198+0c3eb6e2 lld-0:14.0.6-1.module_el8.7.0+1198+0c3eb6e2 compiler-rt-0:14.0.6-1.module_el8.7.0+1198+0c3eb6e2 \
        binaryen emsdk docker-ce npm yarn rpm-build
    
    dnf -y clean all
}

# Build and install Go tools
function install_go_tools() {
    go install -ldflags="-s -w" "google.golang.org/protobuf/cmd/protoc-gen-go@${GOLANG_PROTOBUF_VERSION}"
    go install -ldflags="-s -w" "google.golang.org/grpc/cmd/protoc-gen-go-grpc@${GOLANG_GRPC_PROTOBUF_VERSION}"
    go install -ldflags="-s -w" "github.com/uber/prototool/cmd/prototool@${PROTOTOOL_VERSION}"
    go install -ldflags="-s -w" "github.com/nilslice/protolock/cmd/protolock@${PROTOLOCK_VERSION}"
    go install -ldflags="-s -w" "golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION}"
    go install -ldflags="-s -w" "github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCI_LINT_VERSION}"
    go install -ldflags="-s -w" "github.com/go-bindata/go-bindata/go-bindata@${GO_BINDATA_VERSION}"
    go install -ldflags="-s -w" "github.com/envoyproxy/protoc-gen-validate@${PROTOC_GEN_VALIDATE_VERSION}"
    go install -ldflags="-s -w" "github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@${PROTOC_GEN_GRPC_GATEWAY_VERSION}"
    go install -ldflags="-s -w" "github.com/google/go-jsonnet/cmd/jsonnet@${JSONNET_VERSION}"
    go install -ldflags="-s -w" "github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@${JB_VERSION}"
    go install -ldflags="-s -w" "github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@${PROTOC_GEN_SWAGGER_VERSION}"
    go install -ldflags="-s -w" "github.com/istio/go-junit-report@${GO_JUNIT_REPORT_VERSION}"
    go install -ldflags="-s -w" "sigs.k8s.io/bom/cmd/bom@${BOM_VERSION}"
    go install -ldflags="-s -w" "sigs.k8s.io/kind@${KIND_VERSION}"
    go install -ldflags="-s -w" "github.com/wadey/gocovmerge@${GOCOVMERGE_VERSION}"
    go install -ldflags="-s -w" "github.com/imsky/junit-merger/src/junit-merger@${JUNIT_MERGER_VERSION}"
    go install -ldflags="-s -w" "golang.org/x/perf/cmd/benchstat@${BENCHSTAT_VERSION}"
    go install -ldflags="-s -w" "github.com/google/go-containerregistry/cmd/crane@${CRANE_VERSION}"

    go install -ldflags="-s -w" "istio.io/tools/cmd/protoc-gen-docs@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/annotations_prep@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/cue-gen@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/envvarlinter@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/testlinter@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/protoc-gen-golang-deepcopy@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/protoc-gen-golang-jsonshim@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/kubetype-gen@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/license-lint@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "istio.io/tools/cmd/gen-release-notes@${ISTIO_TOOLS_SHA}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/applyconfiguration-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/defaulter-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/client-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/lister-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/informer-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/deepcopy-gen@kubernetes-${K8S_CODE_GENERATOR_VERSION}"
    go install -ldflags="-s -w" "k8s.io/code-generator/cmd/go-to-protobuf@kubernetes-${K8S_CODE_GENERATOR_VERSION}"

    # pr creator
    mkdir -p /root/test-infra
    pushd /root/test-infra
    git init && git remote add origin https://github.com/kubernetes/test-infra.git
    git fetch --depth 1 origin "${K8S_TEST_INFRA_VERSION}"
    git checkout FETCH_HEAD
    go install ./robots/pr-creator
    go install ./prow/cmd/peribolos
    go install ./prow/cmd/checkconfig
    go install ./pkg/benchmarkjunit
    popd
}

# Install other tools
function install_other_tools() {
    # YQ
    curl -sfL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq-go
    chmod +x /usr/local/bin/yq-go
    
    # GH CLI
    curl -sfLO "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" && \
    tar zxf "gh_${GH_VERSION}_linux_amd64.tar.gz"
    mv "gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin && chown root.root /usr/local/bin/gh

    # Python tools
    pip3 install --no-binary :all: autopep8=="${AUTOPEP8_VERSION}"
    pip3 install yamllint=="${YAMLLINT_VERSION}"
    pip3 install yq && mv /usr/local/bin/yq /usr/local/bin/yq-python
    ln -s /usr/local/bin/yq-go /usr/local/bin/yq

    # ShellCheck linter
    curl -sfL "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" | tar -xJ "shellcheck-${SHELLCHECK_VERSION}/shellcheck" --strip=1
    mv shellcheck /usr/bin/shellcheck

    # Other lint tools
    curl -sfL "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64" -o /usr/bin/hadolint
    chmod +x /usr/bin/hadolint

    # Helm
    curl -sfL "https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz" | tar -xz linux-amd64/helm --strip=1
    mv helm /usr/local/bin/helm && chown root.root /usr/local/bin/helm && ln -s /usr/local/bin/helm /usr/local/bin/helm3

    # Kubectl
    curl -sfL "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl

    # Protoc
    curl -sfLO "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" && \
    unzip "protoc-${PROTOC_VERSION}-linux-x86_64.zip"
    mv bin/protoc /usr/local/bin

    # Promu
    curl -sfLO "https://github.com/prometheus/promu/releases/download/v${PROMU_VERSION}/promu-${PROMU_VERSION}.linux-amd64.tar.gz" && \
    tar -zxvf "promu-${PROMU_VERSION}.linux-amd64.tar.gz"
    mv "promu-${PROMU_VERSION}.linux-amd64/promu" /usr/local/bin && chown root.root /usr/local/bin/promu

    # Google cloud tools
    curl -sfL -o /tmp/gc.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz" && \
    tar -xzf /tmp/gc.tar.gz -C /usr/local && rm -f /tmp/gc.tar.gz

    # Buf
    curl -sfL -o /usr/bin/buf "https://github.com/bufbuild/buf/releases/download/${BUF_VERSION}/buf-Linux-x86_64"
    chmod 555 /usr/bin/buf

    # su-exec
    mkdir /tmp/su-exec && pushd /tmp/su-exec
    curl -sfL -o /tmp/su-exec/su-exec.tar.gz "https://github.com/ncopa/su-exec/archive/v${SU_EXEC_VERSION}.tar.gz" && \
    tar xfz /tmp/su-exec/su-exec.tar.gz
    pushd "su-exec-${SU_EXEC_VERSION}" && make
    cp -a su-exec /usr/local/bin
    chmod u+sx /usr/local/bin/su-exec
    popd
    popd

    # Bazel
    curl -o /usr/bin/bazel -Ls "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64"
    chmod +x /usr/bin/bazel

    # FPM
    mkdir -p /tmp/fpm
    pushd /tmp/fpm
    git init && git remote add origin https://github.com/jordansissel/fpm && \
    git fetch --depth 1 origin "${FPM_VERSION}" && git checkout FETCH_HEAD
    make install
    popd

    # MDL
    gem install --no-wrappers --no-document mdl -v "${MDL_VERSION}"

    # Rust (for WASM filters)
    export CARGO_HOME="/rust"
    export RUSTUP_HOME="/rust"
    mkdir /rust && chmod 777 /rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    /rust/bin/rustup target add wasm32-unknown-unknown
}

function cleanup_cache() {
    rm -rf /var/cache/yum
    rm -rf /root/* /root/.cache /tmp/* /gocache/* /go/pkg
}

function builder_config() {
    mkdir -p /work && chmod 777 /work

    # Workarounds for proxy and bazel
    useradd user && chmod 777 /home/user
    export USER=user 
    export HOME=/home/user
    ln -s /usr/bin/python3 /usr/bin/python && alternatives --set python3 /usr/bin/python3.8
    ln -s /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt

    # mountpoints are mandatory for any host mounts.
    # mountpoints in /config are special.
    mkdir -p /go /gocache /gobin /config/.docker /config/.config/gcloud \
        /config/.kube /config-copy /home/.cache /home/.helm /home/.gsutil

    # TODO must sort out how to use uid mapping in docker so these don't need to be 777
    # They are created as root 755.  As a result they are not writeable, which fails in
    # the developer environment as a volume or bind mount inherits the permissions of
    # the directory mounted rather then overridding with the permission of the volume file.
    chmod 777 /go /gocache /gobin /config /config/.docker /config/.config/gcloud \
        /config/.kube /home/.cache /home/.helm /home/.gsutil
}

install_rpm_deps
install_go_tools
install_other_tools
cleanup_cache
builder_config