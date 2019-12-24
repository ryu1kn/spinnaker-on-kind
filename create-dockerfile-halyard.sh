#!/bin/bash

set -euo pipefail

cat <<EOF
FROM localhost:5000/$1

COPY $2 $3
EOF
