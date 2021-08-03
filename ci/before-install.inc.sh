#!/usr/bin/env bash

function sf_rvm_unfuck() {
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
sf_rvm_unfuck


# github action set-env
function sf_ga_set_env() {
    echo "$1" | ${SF_SUDO} tee -a ${GITHUB_ENV} >/dev/null
}


function sf_github_https_deploy() {
    # if we have a deploy token, use that to authenticate https for the current repo
    # and don't require SSH keys

    echo_info "Found SF_GH_TOKEN_DEPLOY."
    echo_do "Setting up authenticated HTTPS-protocol for all SSH-protocol api.github.com URLs..."
    echo -e "machine api.github.com\n  login ${SF_GH_TOKEN_DEPLOY}" >> ${HOME}/.netrc

    echo_do "Setting up authenticated HTTPS-protocol for current repo's origin..."
    exe git remote -v show
    exe git remote set-url origin https://${SF_GH_TOKEN_DEPLOY}@github.com/${CI_REPO_SLUG}.git
    echo_done
}


function sf_github_https_insteadof_git() {
    # NOTE git (over ssh) is a smarter protocol than https
    # but requires SSH keys, though there's no security server-side

    echo_do "Setting up HTTPS-protocol for all GIT-protocol github.com URLs..."
    # cover git canonical git url
    git config --global --add url."https://github.com/".insteadOf "git://github.com/"
    # cover github url
    git config --global --add url."https://github.com/".insteadOf "github://"
    echo_done
}


function sf_github_https_insteadof_all() {
    # if we have a personal access token, use that to authenticate https
    # and don't require SSH keys

    echo_info "Found SF_GH_TOKEN."
    echo_do "Setting up authenticated HTTPS-protocol for all SSH-protocol github.com URLs..."
    echo -e "machine github.com\n  login ${SF_GH_TOKEN}" >> ${HOME}/.netrc
    echo_do "Setting up authenticated HTTPS-protocol for all SSH-protocol api.github.com URLs..."
    echo -e "machine api.github.com\n  login ${SF_GH_TOKEN}" >> ${HOME}/.netrc

    # cover git canonical git url
    git config --global --add url."https://github.com/".insteadOf "git://github.com/"
    # cover git canonical ssh url
    git config --global --add url."https://github.com/".insteadOf "git@github.com:"
    # cover github url
    git config --global --add url."https://github.com/".insteadOf "github://"
    # cover npm package.json's canonical git+ssh url
    git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
    echo_done
}


function sf_github() {
    # NOTE we need to prepend to .gitconfig, or else settings are ignored
    # due to url settings in gitconfig/dot.gitconfig

    local GITCONFIG_BAK=$(mktemp)
    [[ ! -e "${HOME}/.gitconfig" ]] || {
        mv ${HOME}/.gitconfig ${GITCONFIG_BAK}
        touch ${HOME}/.gitconfig
    }

    # GH_TOKEN is a common way to pass a personal access token to CI jobs
    export SF_GH_TOKEN=${SF_GH_TOKEN:-${GH_TOKEN:-}}
    if [[ "${GITHUB_ACTIONS:-}" = true ]]; then
        # GITHUB_TOKEN is Github Actions' default deploy key
        export SF_GH_TOKEN_DEPLOY=${SF_GH_TOKEN_DEPLOY:-${GITHUB_TOKEN:-}}
    else
        # GITHUB_TOKEN is also common way to pass a personal access token to CI jobs, IFF not on Github Actions
        export SF_GH_TOKEN=${SF_GH_TOKEN:-${GITHUB_TOKEN:-}}
        export SF_GH_TOKEN_DEPLOY=${SF_GH_TOKEN}
    fi

    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env "SF_GH_TOKEN=${SF_GH_TOKEN}"
    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env  "SF_GH_TOKEN_DEPLOY=${SF_GH_TOKEN_DEPLOY}"

    if [[ -n "${SF_GH_TOKEN:-}" ]]; then
        sf_github_https_insteadof_all
    else
        sf_github_https_insteadof_git
        [[ -z "${SF_GH_TOKEN_DEPLOY:-}" ]] || sf_github_https_deploy
    fi

    # shellcheck disable=SC2094
    cat ${HOME}/.gitconfig ${GITCONFIG_BAK} | ${SUPPORT_FIRECLOUD_DIR}/bin/sponge ${HOME}/.gitconfig

    echo_do "Printing ${HOME}/.gitconfig ..."
    cat ${HOME}/.gitconfig
    echo_done

    GIT_HTTPS_URL="https://github.com/actions/runner.git"
    [[ -z "${SF_GH_TOKEN:-}" ]] || \
        git ls-remote --get-url git@github.com:actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
    git ls-remote --get-url git://github.com/actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
    git ls-remote --get-url github://actions/runner.git | grep -q -Fx "${GIT_HTTPS_URL}"
}


function sf_transcrypt() {
    # de-transcrypt only for non-PRs or for PRs from the same repo
    [[ "${CI_IS_PR:-}" != "true" ]] || {
        [[ "${CI_PR_SLUG}" = "${CI_REPO_SLUG}" ]] || return 0
    }
    [[ -x "./transcrypt" ]] || return 0
    [[ -n "${SF_TRANSCRYPT_PASSWORD:-${TRANSCRYPT_PASSWORD:-}}" ]] || return 0

    if git config --local transcrypted.version >/dev/null; then
        echo_skip "${FUNCNAME[0]}: Repository isn't transcrypted..."
        return 0
    fi

    echo_do "Found SF_TRANSCRYPT_PASSWORD, setting up transcrypt..."
    # see https://github.com/elasticdog/transcrypt/issues/37
    # see https://stackoverflow.com/a/34808299/465684
    git update-index -q --really-refresh
    ./transcrypt \
        -y \
        -c "${SF_TRANSCRYPT_CIPHER:-${TRANSCRYPT_CIPHER:-aes-256-cbc}}" \
        -p "${SF_TRANSCRYPT_PASSWORD:-${TRANSCRYPT_PASSWORD:-}}"

    unset SF_TRANSCRYPT_CIPHER
    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env "SF_TRANSCRYPT_CIPHER="
    unset TRANSCRYPT_CIPHER
    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env "TRANSCRYPT_CIPHER="

    unset SF_TRANSCRYPT_PASSWORD
    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env "SF_TRANSCRYPT_PASSWORD="
    unset TRANSCRYPT_PASSWORD
    [[ "${GITHUB_ACTIONS:-}" != "true" ]] || sf_ga_set_env "TRANSCRYPT_PASSWORD="

    echo_done
}


function sf_os_get_dir_owner() {
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

function sf_os_bootstrap_with_script() {
    BOOTSTRAP_SCRIPT=$1

    # recursive chown is slow in Docker, but linuxbrew requires the invoking user to own the linuxbrew folders
    # so the bootstrap script (which invokes linuxbrew) needs to run as the same user that is owning the folders
    # see https://github.com/docker/for-linux/issues/388
    local BOOTSTRAP_SCRIPT_USER=$(id -u -n)
    if command -v brew >/dev/null 2>&1; then
        BOOTSTRAP_SCRIPT_USER=$(sf_os_get_dir_owner $(brew --prefix)/Homebrew)
    elif test -x /home/linuxbrew/.linuxbrew/bin/brew; then
        BOOTSTRAP_SCRIPT_USER=$(sf_os_get_dir_owner $(/home/linuxbrew/.linuxbrew/bin/brew --prefix)/Homebrew)
    elif test -x ${HOME}/.linuxbrew/bin/brew; then
        BOOTSTRAP_SCRIPT_USER=$(sf_os_get_dir_owner $(${HOME}/.linuxbrew/bin/brew --prefix)/Homebrew)
    fi

    if [[ "$(id -u -n)" = "${BOOTSTRAP_SCRIPT_USER}" ]]; then
        echo_info "Running ${BOOTSTRAP_SCRIPT} as current user $(id -u -n)."
        ${BOOTSTRAP_SCRIPT}
    else
        echo_info "Running ${BOOTSTRAP_SCRIPT} as another user ${BOOTSTRAP_SCRIPT_USER}."
        sudo --preserve-env --set-home --user ${BOOTSTRAP_SCRIPT_USER} ${BOOTSTRAP_SCRIPT}
    fi
}


function sf_os() {
    [[ "${SF_FORCE_BOOTSTRAP:-}" = "true" ]] || {
        SF_GIT_HASH=$(git -C ${SUPPORT_FIRECLOUD_DIR} rev-parse HEAD)
        [[ ! -f /support-firecloud.bootstrapped ]] || {
            SF_GIT_HASH_BOOTSTRAPPED=$(cat /support-firecloud.bootstrapped)
            echo_info "${FUNCNAME[0]}: /support-firecloud.bootstrapped exists."
            echo_info "${FUNCNAME[0]}: /support-firecloud.bootstrapped references ${SF_GIT_HASH_BOOTSTRAPPED}."
            echo_info "${FUNCNAME[0]}: ${SUPPORT_FIRECLOUD_DIR} references ${SF_GIT_HASH}."
            if [[ "${SF_GIT_HASH}" = "${SF_GIT_HASH_BOOTSTRAPPED}" ]]; then
                echo_info "${FUNCNAME[0]}: Match found. Bootstrapping without brew bootstrap."
                echo_info "${FUNCNAME[0]}: Running with SF_SKIP_BREW_BOOTSTRAP=true."
                echo_info "${FUNCNAME[0]}: Running with SF_SKIP_SUDO_BOOTSTRAP=true."
                export SF_SKIP_BREW_BOOTSTRAP=true
                export SF_SKIP_SUDO_BOOTSTRAP=true
                export SF_LOG_BOOTSTRAP=true
            else
                echo_info "${FUNCNAME[0]}: Match not found. Bootstrapping from scratch."
            fi
        }
    }

    [[ "${CI_DEBUG_MODE:-}" != "true" ]] || {
        SF_LOG_BOOTSTRAP=${SF_LOG_BOOTSTRAP:-true}
    }
    echo_info "${FUNCNAME[0]}: Running with"
    echo_info "${FUNCNAME[0]}: SF_LOG_BOOTSTRAP=${SF_LOG_BOOTSTRAP:-}"
    echo_info "${FUNCNAME[0]}: SF_PRINTENV_BOOTSTRAP=${SF_PRINTENV_BOOTSTRAP:-}"

    local BOOTSTRAP_SCRIPT="${SUPPORT_FIRECLOUD_DIR}/bootstrap/${OS_SHORT}/bootstrap"

    if [[ "${SF_LOG_BOOTSTRAP:-}" = "true" ]]; then
        sf_os_bootstrap_with_script ${BOOTSTRAP_SCRIPT}
        return 0
    fi

    local TMP_SF_OS_LOG=$(mktemp)
    echo_info "${FUNCNAME[0]}: Redirecting into ${TMP_SF_OS_LOG} to minimize CI log..."

    echo " 0 1 2 3 4 5 6 7 8 9101112131415 min"
    while :;do echo -n " ."; /bin/sleep 60; done &
    local WHILE_LOOP_PID=$!
    # shellcheck disable=SC2064
    trap "kill ${WHILE_LOOP_PID}" EXIT
    sf_os_bootstrap_with_script ${BOOTSTRAP_SCRIPT} >${TMP_SF_OS_LOG} 2>&1 || {
        hash -r
        echo
        echo_err "${FUNCNAME[0]}: Failed. The latest log tail follows:"
        tail -n1000 ${TMP_SF_OS_LOG}
        sleep 10 # see https://github.com/travis-ci/travis-ci/issues/6018
        return 1
    }
    hash -r
    echo
    kill ${WHILE_LOOP_PID} && trap " " EXIT
}


function sf_pyenv_init() {
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
}


function sf_ci_run_before_install() {
    sf_github
    sf_transcrypt
    sf_os
    sf_pyenv_init

    [[ "${CI_DEBUG_MODE:-}" != "true" ]] || {
        echo
        echo "  Please run \`./.ci.sh debug\` to activate your debug session !!!"
        echo
    }
}
