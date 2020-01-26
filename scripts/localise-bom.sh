#!/bin/bash

set -euo pipefail

source "$(dirname "$BASH_SOURCE")/lib/config.sh"

yq -y ".version |= \"local:\(.)\"
    | .services |= map_values(if .version then .version |= \"local:\(.)\" else . end)
    | .artifactSources.dockerRegistry |= \"registry:$(get_config registry_port)\""
