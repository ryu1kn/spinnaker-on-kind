#!/bin/bash

set -euo pipefail

urlencode() { sed 's|/|%2F|g' <<< "$1"; }

download() {
    local gs_path="${1#gs://}"
    local bucket="${gs_path%%/*}"
    local object_path="${gs_path#${bucket}/}"
    wget -O "$2" "https://storage.googleapis.com/download/storage/v1/b/$bucket/o/$(urlencode "$object_path")?alt=media"
}

list_objects() {
    curl -s "https://storage.googleapis.com/storage/v1/b/halconfig/o?prefix=$(urlencode "$1")" | jq -r '.items[]?.id' | sed 's|/[0-9]*$||'
}

readonly version=$1
readonly boms_dir=__spinnaker-versions
readonly version_dir="$boms_dir/$version"
readonly bom_file="$version_dir/bom/$version.yml"

mkdir -p "$(dirname "$bom_file")"
download "gs://halconfig/bom/$version.yml" "$bom_file"

readonly service_dir_paths=$(yq r -j "$bom_file" | jq -r '.services | to_entries | map("\(.key)/\(.value.version)")[]')

for dir_path in $service_dir_paths ; do
    [[ $dir_path = */null ]] && continue

    files="$(list_objects "$dir_path")"
    [[ -z $files ]] && continue

    service_dir="$version_dir/${dir_path%%/*}"
    mkdir -p "$service_dir"
    for file in $files ; do
        download "gs://$file" "$service_dir/${file##*/}"
    done
done
