FROM alpine:3.7

RUN apk add --no-cache make bash jq curl tar python3 py3-pip \
    \
    && helm_artifact=helm-v3.0.2-linux-amd64.tar.gz \
    && wget -q "https://get.helm.sh/$helm_artifact" \
    && tar -xzf "$helm_artifact" \
    && mv linux-amd64/helm /usr/local/bin \
    && rm -rf linux-amd64 "$helm_artifact" \
    \
    && pip3 install yq
