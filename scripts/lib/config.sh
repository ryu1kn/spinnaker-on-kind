#!/bin/bash

dir="$(dirname "$BASH_SOURCE")"

get_config() {
    make -f "$dir/../../config.mk" -s "print-$1"
}
