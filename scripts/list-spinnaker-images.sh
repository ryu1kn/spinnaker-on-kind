#!/bin/bash

source "$(dirname "$BASH_SOURCE")/lib/config.sh"

readonly bom_file="$1"

yq -r ".services
    | to_entries
    | map(
        select(.value.version != null and .key != \"monitoring-third-party\")
        | \"$(get_config spinnaker_docker_repository)/\(.key):\(.value.version)\")[]" "$bom_file"
