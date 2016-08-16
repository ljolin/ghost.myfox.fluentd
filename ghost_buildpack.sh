#!/bin/bash
# https://myfox.ghost.morea.fr/doc/rst/scripts.html
set -e

ALLOWED_APPS=("shcp api videocloud consumers")

if [ ${#} -ne 1 ]; then
  echo "ERROR: This script needs exactly one arguments (app name)"
  exit 1
fi
if ! [[ "${ALLOWED_APPS}" =~ "${1}" ]]; then
  echo "ERROR: App ${1} not allowed, allowed apps : ${ALLOWED_APPS}"
  exit 1
fi

# Enable application configuration
mv ${1} config.d

# Remove unused directories
find . -maxdepth 1 -type d -not -name "config.d" -exec rm -rf {} \;
