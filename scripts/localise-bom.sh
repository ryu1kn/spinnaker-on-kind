#!/bin/bash

set -euo pipefail

source "$(dirname "$BASH_SOURCE")/lib/config.sh"

yaml_wrap() {
    yq read - -j | "$@" | yq read -
}

yaml_wrap jq "
    .version |= \"local:\(.)\"
    | .services |= map_values(if .version then .version |= \"local:\(.)\" else . end)
    | .artifactSources.dockerRegistry |= \"registry:$(get_config registry_port)\""
