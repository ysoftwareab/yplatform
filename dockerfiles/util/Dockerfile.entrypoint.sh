#!/usr/bin/env bash
# -*- mode: sh -*-

# Run all /Dockerfile.entrypoint.d/*.sh entrypoints based on filename order
# see https://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts
# see https://github.com/camptocamp/docker-git/blob/master/docker-entrypoint.sh

if [[ -d "/Dockerfile.entrypoint.d" ]] && [[ -n "$(ls -A /Dockerfile.entrypoint.d)" ]]; then
    /yplatform/bin/linux-run-parts --verbose --regex "\.sh$" "/Dockerfile.entrypoint.d"
fi

>&2 echo "$(date +"%H:%M:%S")" "[INFO]" "${BASH_SOURCE[0]}:" "$@"
exec "$@"
