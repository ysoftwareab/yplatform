#!/usr/bin/env bash
set -euo pipefail

git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"
