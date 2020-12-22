#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing Perl packages..."
else
    echo_do "brew: Installing Perl packages..."
    # installing perl for performance reasons, since it takes a very long time to install via homebrew,
    # and quite a few formulas require it
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    case "${OS_SHORT}" in
        darwin)
            brew_install_one perl
            ;;
        linux)
            # TODO installing via apt as a workaround for Travis Ubuntu 20.04 running gcc 9.2.1
            # /usr/lib/gcc/x86_64-linux-gnu/9/include-fixed/bits/statx.h:38:25: error: missing binary operator before token "("
            # #if __glibc_has_include ("__linux__/stat.h")
            #                         ^
            brew_install_one perl || apt_install_one perl
            ;;
        *)
            echo_err "OS_SHORT=${OS_SHORT}"
            exit 1
            ;;
    esac
    echo_done
fi
