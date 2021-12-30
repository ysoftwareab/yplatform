#!/usr/bin/env bash
set -euo pipefail

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${YP_DIR}/sh/common.inc.sh

LOCAL_GITATTRIBUTESS="\
    gitconfig/dot.gitattributes_whitespace
    gitconfig/dot.gitattributes_builtin
    gitconfig/dot.gitattributes_builtin_diff
    gitconfig/dot.gitattributes_text
    gitconfig/dot.gitattributes_text_diff
    gitconfig/dot.gitattributes_binary
    gitconfig/dot.gitattributes_binary_diff
    gitconfig/dot.gitattributes_exclusions
    gitconfig/dot.gitattributes_export_ignore
"

echo "# -*- mode: Gitattributes -*-"

echo
echo "# BEGIN gitconfig/dot.gitattributes_global.base"
echo
cat ${GIT_ROOT}/gitconfig/dot.gitattributes_global.base
echo
echo "# END gitconfig/dot.gitattributes_global.base"

for LOCAL_GITATTRIBUTES in ${LOCAL_GITATTRIBUTESS}; do
    echo
    echo "# BEGIN ${LOCAL_GITATTRIBUTES}"
    echo
    cat ${LOCAL_GITATTRIBUTES}
    echo
    echo "# END ${LOCAL_GITATTRIBUTES}"
done
