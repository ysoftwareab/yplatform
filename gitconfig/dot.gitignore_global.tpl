#!/usr/bin/env bash
set -euo pipefail

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"
source ${YP_DIR}/sh/common.inc.sh

# shellcheck disable=SC1091
GITHUB_GLOBAL_GITIGNORE_COMMITISH=$(source ${YP_DIR}/CONST.inc && echo "${YP_GITHUB_GITIGNORE_VSN}")
GITHUB_GLOBAL_GITIGNORE_BASE_URL="https://raw.githubusercontent.com/github/gitignore/${GITHUB_GLOBAL_GITIGNORE_COMMITISH}/Global" # editorconfig-checker-disable-line

# Removing the Emacs gitignore template because it's overly agressive,
# ignoring things like  all "server" or "dist" folders.
GITHUB_GLOBAL_GITIGNORES="\
    Backup \
    Linux \
    Patch \
    Vim \
    VisualStudioCode \
    Windows \
    macOS \
"

LOCAL_GITIGNORES="\
"

mkdir -p ${GIT_ROOT}/gitconfig/github-global-gitignore
for GITHUB_GLOBAL_GITIGNORE in ${GITHUB_GLOBAL_GITIGNORES}; do
    curl -qfsSL -o ${GIT_ROOT}/gitconfig/github-global-gitignore/${GITHUB_GLOBAL_GITIGNORE}.gitignore \
        ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore
done

echo "# -*- mode: Gitignore -*-"

echo
echo "# BEGIN gitconfig/dot.gitignore_global.base"
echo
cat ${GIT_ROOT}/gitconfig/dot.gitignore_global.base
echo
echo "# END gitconfig/dot.gitignore_global.base"

for GITHUB_GLOBAL_GITIGNORE in ${GITHUB_GLOBAL_GITIGNORES}; do
    echo
    echo "################################################################################"
    echo
    echo "# BEGIN ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore"
    echo
    cat ${GIT_ROOT}/gitconfig/github-global-gitignore/${GITHUB_GLOBAL_GITIGNORE}.gitignore
    echo
    echo "# END ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore"
done

for LOCAL_GITIGNORE in ${LOCAL_GITIGNORES}; do
    echo
    echo "# BEGIN ${LOCAL_GITIGNORE}"
    echo
    cat ${LOCAL_GITIGNORE}
    echo
    echo "# END ${LOCAL_GITIGNORE}"
done
