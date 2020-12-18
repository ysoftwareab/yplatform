#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

GITHUB_GLOBAL_GITIGNORE_BASE_URL="https://raw.githubusercontent.com/github/gitignore/master/Global"

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

mkdir -p ${GIT_ROOT}/gitconfig/github-global-gitignore
for GITHUB_GLOBAL_GITIGNORE in ${GITHUB_GLOBAL_GITIGNORES}; do
    curl -fqsSL -o ${GIT_ROOT}/gitconfig/github-global-gitignore/${GITHUB_GLOBAL_GITIGNORE}.gitignore \
        ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore
done

echo "# -*- mode: Gitignore -*-"
echo
echo "# BEGIN gitconfig/dot.gitignore_global.base"
echo
cat ${GIT_ROOT}/gitconfig/dot.gitignore_global.base
echo
echo "# END gitconfig/dot.gitignore_global.base"
echo

for GITHUB_GLOBAL_GITIGNORE in ${GITHUB_GLOBAL_GITIGNORES}; do
    echo "################################################################################"
    echo
    echo "# BEGIN ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore"
    echo
    cat ${GIT_ROOT}/gitconfig/github-global-gitignore/${GITHUB_GLOBAL_GITIGNORE}.gitignore
    echo
    echo "# END ${GITHUB_GLOBAL_GITIGNORE_BASE_URL}/${GITHUB_GLOBAL_GITIGNORE}.gitignore"
    echo
done
