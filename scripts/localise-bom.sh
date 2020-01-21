#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/../config.sh"

yaml_wrap() {
    yq read - -j | "$@" | yq read -
}

yaml_wrap jq "
    .version |= \"local:\(.)\"
    | .services |= map_values(if .version then .version |= \"local:\(.)\" else . end)
    | .artifactSources.dockerRegistry |= \"registry:$registry_port\""
