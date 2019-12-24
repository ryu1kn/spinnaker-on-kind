#!/bin/bash

readonly bom=$1

yaml_wrap() {
    local input="$1"
    shift
    yq read "$input" -j | jq "$@" | yq read -
}

yaml_wrap "$bom" '.services |= map_values(if .version then .version |= "local:\(.)" else . end)
    | .artifactSources.dockerRegistry |= "registry:5000"'
