#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing git-diff helpers..."
brew_install_one_unless bzip2 "bzip2 --help 2>&1 | head -1" "^bzip2, a block-sorting file compressor.  Version 1\."
brew_install_one_unless docx2txt "docx2txt.sh | head -2 | tail -1" "^Usage :"
# NOTE skipping if no perl is available
! command -v perl >/dev/null 2>&1 || {
    brew_install_one_unless exiftool "exiftool -ver | head -1" "^12\."
}
case ${OS_SHORT} in
    darwin)
        brew_install_one_unless odt2txt "odt2txt --version | head -1" "^odt2txt 0\."
        ;;
    linux)
        # ODT2TXT_VSN="$(brew info --json=v1 odt2txt | jq -r ".[0].versions.stable")"
        # magic_install_one_unless odt2txt@${ODT2TXT_VSN} "odt2txt --version | head -1" "^odt2txt 0\."
        magic_install_one_unless odt2txt "odt2txt --version | head -1" "^odt2txt 0\."
        ;;
    *)
        echo_err "${OS_SHORT} is an unsupported OS for installing odt2txt"
        exit 1
esac
case ${OS_SHORT} in
    darwin)
        brew_install_one_unless poppler "pdftotext -v 2>&1 | head -1" "^pdftotext version 2[0-9]\."
        ;;
    linux)
        # POPPLER_VSN="$(brew info --json=v1 poppler | jq -r ".[0].versions.stable")"
        # magic_install_one_unless poppler@${POPPLER_VSN} "pdftotext -v 2>&1 | head -1" "^pdftotext version 2[0-9]\."
        magic_install_one_unless poppler "pdftotext -v 2>&1 | head -1" "^pdftotext version "
        ;;
    *)
        echo_err "${OS_SHORT} is an unsupported OS for installing odt2txt"
        exit 1
esac
brew_install_one_unless xz "xz --version | head -1" "^xz (XZ Utils) 5\."
echo_done
