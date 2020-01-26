#!/bin/bash

readonly jq_query="${1:-.}"
readonly yaml_input="${2:--}"
yq read "$yaml_input" -j | jq "$jq_query" | yq read -
