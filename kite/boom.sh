#!/usr/bin/env bash
set -euo pipefail

# Frame Extraction Challenge (node.js)
# Design a JavaScript function getYoutubeFrames() that:
# - Takes a Youtube url as its input
# - Fetches the video
# - Extracts a frame from every scene/cut of the video (hint: use ffmpeg)
# - Converts every frame to jpg format with maximum 800px width
# - **Returns** a list of temp paths or base64 buffers

# deps -------------------------------------------------------------------------
command -v youtube-dl 2>/dev/null || {
    >&2 echo "[DO  ] No youtube-dl found. Installing via brew..."
    brew install youtube-dl
    >&2 echo "[DONE]"
}

command -v ffmpeg 2>/dev/null || {
    >&2 echo "[DO  ] No ffmpeg found. Installing via brew..."
    brew install ffmpeg
    >&2 echo "[DONE]"
}

# setup ------------------------------------------------------------------------

TMP_BOOM="$(mktemp -d -t boom-XXXXXXXXXX)"
>&2 echo "[INFO] Setting working dir to temp dir ${TMP_BOOM}..."
mkdir -p "${TMP_BOOM}"
cd "${TMP_BOOM}"

# main -------------------------------------------------------------------------

>&2 echo "[Q   ] What video url should we extract scene-change frames from?"
>&2 echo "       Example: https://vimeo.com/575996892"
read -r URL
>&2 echo "[DO  ] Downloading ${URL}..."
FILENAME="$(youtube-dl --get-filename "${URL}")"
# cheating. scene-change images need to be max-width 800px
youtube-dl -f "bestvideo[width<=800]/best[width<=800]" "${URL}"
>&2 echo "[DONE]"

>&2 echo "[DO  ] Extracting scene-change frames as JPG images..."
ffmpeg -i "${FILENAME}" -vf "select=gt(scene\,0.7)" -vsync vfr scene-%04d.jpg
>&2 echo "[DONE]"

# result -----------------------------------------------------------------------

>&2 echo "[INFO] Scene-change images:"
ls -w1 "${PWD}"/scene-*.jpg
