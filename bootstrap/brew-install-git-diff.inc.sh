#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing git-diff helpers..."
brew_install_one_if bzip2 "bzip2 --help 2>&1 | head -1" "^bzip2, a block-sorting file compressor.  Version 1\."
brew_install_one_if docx2txt "docx2txt.sh | head -2 | tail -1" "^Usage :"
# NOTE skipping if no perl is available
! which perl >/dev/null 2>&1 || {
    brew_install_one_if exiftool "exiftool -ver | head -1" "^12\."
}
brew_install_one_if odt2txt "odt2txt --version | head -1" "^odt2txt 0\." || {
    # no bottle on linuxbrew
    brew install --build-from-source odt2txt
    exe_and_grep_q "odt2txt --version | head -1" "^odt2txt 0\."
}
# NOTE alternatively one can also install xpdf instead of poppler. Uncertain about the diffs.
# brew_install_one_if xpdf "pdftotext -v 2>&1 | head -1" "^pdftotext version 4\."
brew_install_one_if poppler "pdftotext -v 2>&1 | head -1" "^pdftotext version 2[0-9]\." || {
    # no bottle on linuxbrew
    # brew ls | grep -q "qt@5" || brew install --build-from-source qt@5
    # brew install --build-from-source poppler

    EXIT_CODE=$?
    [[ "${OS_SHORT}" = "linux" ]] || exit ${EXIT_CODE}
    echo_warn "Falling back to installing Poppler outside Homebrew..."

    # POPPLER_VSN="$(brew info --json=v1 poppler | jq -r ".[0].versions.stable")"
    # magic_install_one poppler@${POPPLER_VSN}
    # exe_and_grep_q "pdftotext -v 2>&1 | head -1" "^pdftotext version 2[0-9]\."
    magic_install_one poppler
    exe_and_grep_q "pdftotext -v 2>&1 | head -1" "^pdftotext version "
}
brew_install_one_if xz "xz --version | head -1" "^xz (XZ Utils) 5\."
echo_done
