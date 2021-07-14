#!/usr/bin/env bash

# Run all /Dockerfile.entrypoint.d/*.sh entrypoints based on filename order
# see https://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts
# see https://github.com/camptocamp/docker-git/blob/master/docker-entrypoint.sh

[[ ! -d "/Dockerfile.entrypoint.d" ]] || \
    /bin/run-parts --verbose --regex "\.sh$" "/Dockerfile.entrypoint.d"

exec "$@"
