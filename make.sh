#!/usr/bin/env bash

# This script is a dummy script, just to test the functionality of sh/env.inc.sh:make.

[[ -n "${YP_MAKE_COMMAND:-}" ]] || {
    >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Expected YP_MAKE_COMMAND to be defined. Maybe GNU Make is not available."
    exit 1;
}

${YP_MAKE_COMMAND} "$@"
