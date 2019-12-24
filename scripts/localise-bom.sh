#!/bin/bash

set -euo pipefail

yaml_wrap() {
    yq read - -j | "$@" | yq read -
}

yaml_wrap jq '
    .version |= "local:\(.)"
    | .services |= map_values(if .version then .version |= "local:\(.)" else . end)
    | .artifactSources.dockerRegistry |= "registry:5000"'
