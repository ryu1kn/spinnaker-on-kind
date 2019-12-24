#!/bin/bash

set -euo pipefail

readonly local_registry=localhost:5000
readonly image_list_file="$1"

while read -r image; do
    [[ $image = \#* ]] && continue

    docker pull "$image"

    local_image="$local_registry/${image##*/}"
    docker tag "$image" "$local_image"
    docker push "$local_image"
done < "$image_list_file"

