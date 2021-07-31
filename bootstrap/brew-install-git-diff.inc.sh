#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing git-diff helpers..."
brew_install_one_if bzip2 "bzip2 --help 2>&1 | head -1" "^bzip2, a block-sorting file compressor.  Version 1\."
brew_install_one_if docx2txt "docx2txt.sh | head -2 | tail -1" "^Usage :"
brew_install_one_if exiftool "exiftool -ver | head -1" "^12\."
brew_install_one_if odt2txt "odt2txt --version | head -1" "^odt2txt 0\." || {
    # no bottle on linuxbrew
    brew install --build-from-source odt2txt
    exe_and_grep_q "odt2txt --version | head -1" "^odt2txt 0\."
}
brew_install_one_if poppler "pdftotext -v | head -1" "^pdftotext version 2[0-9]\." || {
    # no bottle on linuxbrew
    brew install --build-from-source poppler
    exe_and_grep_q "pdftotext -v | head -1" "^pdftotext version 2[0-9]\."
}
brew_install_one_if xz "xz --version | head -1" "^xz (XZ Utils) 5\."
echo_done
