FROM alpine:3.7

ARG HOME
ENV XDG_CACHE_HOME=$HOME/.cache \
    XDG_CONFIG_HOME=$HOME/.config \
    XDG_DATA_HOME=$HOME/.local/share

RUN apk add --no-cache make bash jq curl tar python3 py3-pip \
    \
    && wget -q https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz \
    && tar -xzf helm-v3.0.2-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && rm -rf linux-amd64 helm-v3.0.2-linux-amd64.tar.gz \
    && helm repo add stable https://kubernetes-charts.storage.googleapis.com/ \
    \
    && pip3 install yq \
    \
    && wget https://dl.k8s.io/v1.17.0/kubernetes-client-linux-amd64.tar.gz \
    && tar -xzf kubernetes-client-linux-amd64.tar.gz \
    && mv kubernetes/client/bin/kubectl /usr/local/bin \
    && rm -rf kubernetes kubernetes-client-linux-amd64.tar.gz \
    \
    && curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-linux-amd64 \
    && chmod +x kind \
    && mv kind /usr/local/bin
