#!/usr/bin/env bash
set -euo pipefail

function yp_rvm_unfuck() {
    # from https://github.com/matthew-brett/multibuild/blob/34b988aab60a93fa3c7bd1eb88dd7c4361ca464f/common_utils.sh#L17

    # Work round bug in travis xcode image described at
    # https://github.com/direnv/direnv/issues/210
    shell_session_update() { :; }

    # Workaround for https://github.com/travis-ci/travis-ci/issues/8703
    # suggested by Thomas K at
    # https://github.com/travis-ci/travis-ci/issues/8703#issuecomment-347881274
    unset -f cd
    unset -f pushd
    unset -f popd
}
yp_rvm_unfuck


# github action set-env
function yp_ga_set_env() {
    echo "$1" | ${YP_SUDO} tee -a ${GITHUB_ENV} >/dev/null
}


function yp_github_https_deploy() {
    # if we have a deploy token, use that to authenticate https for the current repo
    # and don't require SSH keys

    local GITHUB_SERVER_URL=${1:-${GITHUB_SERVER_URL}}
    local GITHUB_SERVER_URL_DOMAIN="$(basename "${GITHUB_SERVER_URL}")"
    echo_info "Found YP_GH_TOKEN_DEPLOY."
    
    echo_do "Setting up authenticated HTTPS-protocol for all SSH-protocol ${GITHUB_SERVER_URL_DOMAIN} URLs..."
    case ${YP_GH_TOKEN_DEPLOY:0:4} in
        ghp_)
            echo "machine ${GITHUB_SERVER_URL_DOMAIN}" >> "${HOME}/.netrc"
            echo "  login ${YP_GH_TOKEN_DEPLOY}" >> "${HOME}/.netrc"
            ;;
        ghs_)
            echo "machine ${GITHUB_SERVER_URL_DOMAIN}" >> "${HOME}/.netrc"
            echo "  login x-access-token" >> "${HOME}/.netrc"
            echo "  password ${YP_GH_TOKEN_DEPLOY}" >> "${HOME}/.netrc"
            ;;
        *)
            >&2 echo "[ERR ]" "Unknown Github token format. Only ghp and ghs is supported."
            ;;
    esac
    echo_done

    echo_do "Setting up authenticated HTTPS-protocol for current repo's origin..."
    exe git remote -v show
    exe git remote set-url origin \
        https://${YP_GH_TOKEN_DEPLOY}@${GITHUB_SERVER_URL_DOMAIN}/${YP_CI_REPO_SLUG}.git
    echo_done
}


function yp_github_https_insteadof_git() {
    # NOTE git (over ssh) is a smarter protocol than https
    # but requires SSH keys, though there's no security server-side

    echo_do "Setting up HTTPS-protocol for all GIT-protocol github.com URLs..."

    cat ${HOME}/.gitconfig | grep -q "${YP_DIR}/gitconfig/dot.gitconfig.github-https$" || \
        printf '%s\n%s\n' \
            "$(echo -e "[include]\npath = ${YP_DIR}/gitconfig/dot.gitconfig.github-https")" \
            "$(cat ${HOME}/.gitconfig)" >${HOME}/.gitconfig

    echo_done
}


function yp_github_https_insteadof_all() {
    # if we have a personal access token, use that to authenticate https
    # and don't require SSH keys

    local GITHUB_SERVER_URL=${1:-${GITHUB_SERVER_URL}}
    local GITHUB_SERVER_URL_DOMAIN="$(basename "${GITHUB_SERVER_URL}")"
    echo_info "Found YP_GH_TOKEN."
    
    echo_do "Setting up authenticated HTTPS-protocol for all SSH-protocol ${GITHUB_SERVER_URL_DOMAIN} URLs..."
    case ${YP_GH_TOKEN:0:4} in
        ghp_)
            echo "machine ${GITHUB_SERVER_URL_DOMAIN}" >> "${HOME}/.netrc"
            echo "  login ${YP_GH_TOKEN}" >> "${HOME}/.netrc"
            ;;
        ghs_)
            echo "machine ${GITHUB_SERVER_URL_DOMAIN}" >> "${HOME}/.netrc"
            echo "  login x-access-token" >> "${HOME}/.netrc"
            echo "  password ${YP_GH_TOKEN}" >> "${HOME}/.netrc"
            ;;
        *)
            >&2 echo "[ERR ]" "Unknown Github token format. Only ghp and ghs is supported."
            ;;
    esac

    cat ${HOME}/.gitconfig | grep -q "${YP_DIR}/gitconfig/dot.gitconfig.github-ssh$" || \
        printf '%s\n%s\n' \
            "$(echo -e "[include]\npath = ${YP_DIR}/gitconfig/dot.gitconfig.github-ssh")" \
            "$(cat ${HOME}/.gitconfig)" >${HOME}/.gitconfig

    echo_done
}


function yp_github() {
    # GH_TOKEN is a common way to pass a personal access token to CI jobs
    export YP_GH_TOKEN=${YP_GH_TOKEN:-${GH_TOKEN:-}}
    if [[ "${YP_CI_PLATFORM:-}" = "github" ]]; then
        # GITHUB_TOKEN is Github Actions' default deploy key
        export YP_GH_TOKEN_DEPLOY=${YP_GH_TOKEN_DEPLOY:-${GITHUB_TOKEN:-}}
    else
        # GITHUB_TOKEN is also common way to pass a personal access token to CI jobs, IFF not on Github Actions
        export YP_GH_TOKEN=${YP_GH_TOKEN:-${GITHUB_TOKEN:-}}
        export YP_GH_TOKEN_DEPLOY=${YP_GH_TOKEN}
    fi

    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "YP_GH_TOKEN=${YP_GH_TOKEN}"
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "YP_GH_TOKEN_DEPLOY=${YP_GH_TOKEN_DEPLOY}"

    GIT_HTTPS_URL="https://github.com/actions/runner.git"

    if [[ -n "${YP_GH_TOKEN:-}" ]]; then
        yp_github_https_insteadof_all

        git ls-remote --get-url git@github.com:actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
        git ls-remote --get-url git://github.com/actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
        git ls-remote --get-url github://actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
        git ls-remote --get-url https://github.com/actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
    else
        yp_github_https_insteadof_git
        [[ -z "${YP_GH_TOKEN_DEPLOY:-}" ]] || yp_github_https_deploy

        git ls-remote --get-url git://github.com/actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
        git ls-remote --get-url github://actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
        git ls-remote --get-url https://github.com/actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
    fi
}


function yp_git() {
    ln -sfn ${YP_DIR}/gitconfig/dot.gitignore_global ${HOME}/.gitignore_global
    ln -sfn ${YP_DIR}/gitconfig/dot.gitattributes_global ${HOME}/.gitattributes_global

    cat ${HOME}/.gitconfig | grep -q "${YP_DIR}/gitconfig/dot.gitconfig$" || \
        printf '%s\n%s\n' \
            "$(echo -e "[include]\npath = ${YP_DIR}/gitconfig/dot.gitconfig")" \
            "$(cat ${HOME}/.gitconfig)" >${HOME}/.gitconfig

    yp_github

    echo_do "Printing ${HOME}/.gitconfig ..."
    cat ${HOME}/.gitconfig
    echo_done
}


function yp_transcrypt() {
    # de-transcrypt only for non-PRs or for PRs from the same repo
    [[ "${YP_CI_IS_PR:-}" != "true" ]] || {
        [[ "${YP_CI_PR_REPO_SLUG}" = "${YP_CI_REPO_SLUG}" ]] || return 0
    }
    [[ -x "./transcrypt" ]] || return 0
    [[ -n "${YP_TRANSCRYPT_PASSWORD:-${TRANSCRYPT_PASSWORD:-}}" ]] || return 0

    if git config --local transcrypted.version >/dev/null; then
        echo_skip "${FUNCNAME[0]}: Repository isn't transcrypted..."
        return 0
    fi

    echo_do "Found YP_TRANSCRYPT_PASSWORD, setting up transcrypt..."
    # see https://github.com/elasticdog/transcrypt/issues/37
    # see https://stackoverflow.com/a/34808299/465684
    git update-index -q --really-refresh
    ./transcrypt \
        -y \
        -c "${YP_TRANSCRYPT_CIPHER:-${TRANSCRYPT_CIPHER:-aes-256-cbc}}" \
        -p "${YP_TRANSCRYPT_PASSWORD:-${TRANSCRYPT_PASSWORD:-}}"

    unset YP_TRANSCRYPT_CIPHER
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "YP_TRANSCRYPT_CIPHER="
    unset TRANSCRYPT_CIPHER
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "TRANSCRYPT_CIPHER="

    unset YP_TRANSCRYPT_PASSWORD
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "YP_TRANSCRYPT_PASSWORD="
    unset TRANSCRYPT_PASSWORD
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || yp_ga_set_env "TRANSCRYPT_PASSWORD="

    echo_done
}


function yp_os_get_dir_owner() {
    local GNU_STAT=$(stat --version 2>/dev/null | head -1 | grep -q "GNU" && echo true || echo false)
    case "${GNU_STAT}" in
        true)
            local STAT_FORMAT_ARG="-c"
            local STAT_FORMAT_USER="%U"
            ;;
        false) # assume BSD
            local STAT_FORMAT_ARG="-f"
            local STAT_FORMAT_USER="%Su"
            ;;
        *)
            echo_err "GNU_STAT=${GNU_STAT}"
            exit 1
            ;;
    esac

    stat ${STAT_FORMAT_ARG} ${STAT_FORMAT_USER} $1
}

function yp_os_bootstrap_with_script() {
    BOOTSTRAP_SCRIPT=$1

    # recursive chown is slow in Docker, but linuxbrew requires the invoking user to own the linuxbrew folders
    # so the bootstrap script (which invokes linuxbrew) needs to run as the same user that is owning the folders
    # see https://github.com/docker/for-linux/issues/388
    local BOOTSTRAP_SCRIPT_USER=$(id -u -n)
    if command -v brew >/dev/null 2>&1; then
        BOOTSTRAP_SCRIPT_USER=$(yp_os_get_dir_owner $(brew --repository))
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        BOOTSTRAP_SCRIPT_USER=$(yp_os_get_dir_owner $(/home/linuxbrew/.linuxbrew/bin/brew --repository))
    elif [[ -x ${HOME}/.linuxbrew/bin/brew ]]; then
        BOOTSTRAP_SCRIPT_USER=$(yp_os_get_dir_owner $(${HOME}/.linuxbrew/bin/brew --repository))
    fi

    if [[ "$(id -u -n)" = "${BOOTSTRAP_SCRIPT_USER}" ]]; then
        echo_info "Running ${BOOTSTRAP_SCRIPT} as current user $(id -u -n)."
        ${BOOTSTRAP_SCRIPT}
    else
        echo_info "Running ${BOOTSTRAP_SCRIPT} as another user ${BOOTSTRAP_SCRIPT_USER}."
        sudo --preserve-env --set-home --user ${BOOTSTRAP_SCRIPT_USER} ${BOOTSTRAP_SCRIPT}
    fi
}


function yp_os() {
    [[ "${YP_FORCE_BOOTSTRAP:-}" = "true" ]] || {
        local YP_GIT_HASH=$(git -C ${YP_DIR} rev-parse HEAD)
        [[ ! -f /yplatform.bootstrapped ]] || {
            export YP_SKIP_BREW_UNINSTALL=true
            local YP_GIT_HASH_BOOTSTRAPPED=$(cat /yplatform.bootstrapped)
            echo_info "${FUNCNAME[0]}: /yplatform.bootstrapped exists."
            echo_info "${FUNCNAME[0]}: /yplatform.bootstrapped references ${YP_GIT_HASH_BOOTSTRAPPED}."
            echo_info "${FUNCNAME[0]}: ${YP_DIR} references ${YP_GIT_HASH}."
            if [[ "${YP_GIT_HASH}" = "${YP_GIT_HASH_BOOTSTRAPPED}" ]]; then
                echo_info "${FUNCNAME[0]}: Match found. Bootstrapping without brew bootstrap."
                export YP_SKIP_BREW_BOOTSTRAP=true
                export YP_SKIP_SUDO_BOOTSTRAP=true
            else
                echo_info "${FUNCNAME[0]}: Match not found. Bootstrapping from scratch."
            fi
            unset YP_GIT_HASH_BOOTSTRAPPED
        }
        unset YP_GIT_HASH
    }

    [[ "${YP_CI_DEBUG_MODE:-}" != "true" ]] || {
        YP_LOG_BOOTSTRAP=${YP_LOG_BOOTSTRAP:-true}
    }
    echo_info "${FUNCNAME[0]}: Running with"
    echo_info "${FUNCNAME[0]}: YP_LOG_BOOTSTRAP=${YP_LOG_BOOTSTRAP:-}"
    echo_info "${FUNCNAME[0]}: YP_PRINTENV_BOOTSTRAP=${YP_PRINTENV_BOOTSTRAP:-}"
    echo_info "${FUNCNAME[0]}: YP_SKIP_SUDO_BOOTSTRAP=${YP_SKIP_SUDO_BOOTSTRAP:-}"
    echo_info "${FUNCNAME[0]}: YP_SKIP_BREW_UNINSTALL=${YP_SKIP_BREW_UNINSTALL:-}"
    echo_info "${FUNCNAME[0]}: YP_SKIP_BREW_BOOTSTRAP=${YP_SKIP_BREW_BOOTSTRAP:-}"

    local BOOTSTRAP_SCRIPT="${YP_DIR}/bootstrap/bootstrap"

    if [[ "${YP_LOG_BOOTSTRAP:-}" = "true" ]]; then
        yp_os_bootstrap_with_script ${BOOTSTRAP_SCRIPT}
        return 0
    fi

    local TMP_YP_OS_LOG=$(mktemp -t yplatform.XXXXXXXXXX)
    echo_info "${FUNCNAME[0]}: Redirecting into ${TMP_YP_OS_LOG} to minimize CI log..."

    echo " 0 1 2 3 4 5 6 7 8 9101112131415 min"
    while :;do echo -n " ."; /bin/sleep 60; done &
    local WHILE_LOOP_PID=$!
    # shellcheck disable=SC2064
    trap "kill ${WHILE_LOOP_PID}" EXIT
    yp_os_bootstrap_with_script ${BOOTSTRAP_SCRIPT} >${TMP_YP_OS_LOG} 2>&1 || {
        hash -r
        echo
        echo_err "${FUNCNAME[0]}: Failed. The latest log tail follows:"
        tail -n1000 ${TMP_YP_OS_LOG}
        sleep 10 # see https://github.com/travis-ci/travis-ci/issues/6018
        return 1
    }
    hash -r
    echo

    # NOTE it's not harmful to source, but should really run in a subshell, but then shellcheck goes bananas
    source ${YP_DIR}/sh/package-managers/brew.inc.sh
    source ${YP_DIR}/bootstrap/brew-util/print.inc.sh
    brew_print

    kill ${WHILE_LOOP_PID} && trap " " EXIT
}


function yp_pyenv_init() {
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
}


function yp_ci_run_before_install() {
    yp_git
    yp_transcrypt
    yp_os
    yp_pyenv_init

    [[ "${YP_CI_DEBUG_MODE:-}" != "true" ]] || {
        echo
        echo "  Please run \`./.ci.sh debug\` to activate your debug session !!!"
        echo
    }
}
