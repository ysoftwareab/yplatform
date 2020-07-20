#!/usr/bin/env bash

# This script is a dummy script, just to test the functionality of sh/exe-env.inc.sh:make.

[[ -n "${SF_MAKE_SH_PASS:-}" ]] || {
    echo >&2 "[ERR ] Expected SF_MAKE_SH_PASS to be defined."
    exit 1;
}

$(which -a make | grep "^/" | head -1) $@
