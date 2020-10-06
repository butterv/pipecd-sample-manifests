#!/bin/bash
set -eu

case "$1" in
  "local" | "dev" | "stg" | "prd") ;;
  * )
    echo "The environment is not exist."
    exit 1
    ;;
esac
