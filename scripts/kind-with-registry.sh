#!/bin/bash
# cf. https://kind.sigs.k8s.io/docs/user/local-registry/

set -euo pipefail

source "$(dirname "$BASH_SOURCE")/lib/config.sh"

# desired cluster name; default is "kind"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"

# create registry container unless it already exists
reg_name="$(get_config local_registry_name)"
registry_port="$(get_config registry_port)"
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2> /dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "$registry_port:$registry_port" -e "REGISTRY_HTTP_ADDR=0.0.0.0:$registry_port" --name "${reg_name}" \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${registry_port}"]
    endpoint = ["http://${reg_name}:${registry_port}"]
nodes:
- role: control-plane
  extraMounts:
  - hostPath: $(pwd)/tmp/
    containerPath: /mnt/data
EOF

# connect the registry to the cluster network
docker network connect "$KIND_CLUSTER_NAME" "${reg_name}"

# tell https://tilt.dev to use the registry
# https://docs.tilt.dev/choosing_clusters.html#discovering-the-registry
for node in $(kind get nodes); do
  kubectl annotate node "${node}" "kind.x-k8s.io/registry=localhost:${registry_port}";
done
