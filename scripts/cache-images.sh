#!/bin/bash

set -euo pipefail

source "$(dirname "$BASH_SOURCE")/lib/config.sh"

readonly local_registry="localhost:$(get_config registry_port)"
readonly image_list_file="$1"

while read -r image; do
    [[ $image = \#* ]] && continue

    docker pull "$image"

    local_image="$local_registry/${image##*/}"
    docker tag "$image" "$local_image"
    docker push "$local_image"
done < "$image_list_file"
