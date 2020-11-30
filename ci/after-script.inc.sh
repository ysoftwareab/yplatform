#!/usr/bin/env bash

function sf_ci_run_after_script_upload_job_artifacts() {
    [[ -f .artifacts ]] || {
        echo_skip "${FUNCNAME[0]}: No .artifacts found..."
        return 0
    }

    [[ -n "${GH_TOKEN:-}" ]] || {
        echo_skip "${FUNCNAME[0]}: No GH_TOKEN found..."
        return 0
    }

    echo_do "Uploading job artifacts..."

    local JOB_GIT_REF=refs/jobs/${CI_JOB_ID}

    git checkout --orphan jobs/${CI_JOB_ID}
    git ls-files -- "*/.gitignore" | xargs -r -L1 rm -f
    git reset -- .
    cat .artifacts | xargs -r -L1 git add -f || true

    [[ "${TRAVIS:-}" != "true" ]] || {
        # (Try to) Create log.sh-session
        local CURL_TRAVIS_API_HEADERS=(-H "Travis-API-Version: 3")
        [[ -z "${TRAVIS_API_TOKEN:-}" ]] || {
            CURL_TRAVIS_API_HEADERS+=(-H "Authorization: token ${TRAVIS_API_TOKEN}")
        }
        touch log.sh-session
        curl \
            -sS \
            "${CURL_TRAVIS_API_HEADERS[@]}" \
            https://api.travis-ci.com/job/${TRAVIS_JOB_ID}/log | \
            ${SUPPORT_FIRECLOUD_DIR}/bin/jq -r '.content' >log.sh-session || true
        git add -f log.sh-session
    }

    # Create README.md
    cat <<-EOF >README.md
${JOB_GIT_REF}

# Job [${CI_JOB_ID}](${CI_JOB_URL})

## Artifacts

$(git ls-files | xargs -r -I {} echo "* [{}]({})")

EOF
    git add -f README.md

    git commit -m "${CI_JOB_ID}"
    local JOB_GIT_HASH=$(git rev-parse HEAD)

    # Upload to git refs/job/<job_id>
    git push --no-verify -f https://${GH_TOKEN}@github.com/${CI_REPO_SLUG}.git HEAD:${JOB_GIT_REF} || true

    git checkout -f -

    echo_done

    local JOB_GITHUB_UI_URL=https://github.com/${CI_REPO_SLUG}/tree/${JOB_GIT_HASH}

    echo
    echo_info "View job artifacts on Github: ${JOB_GITHUB_UI_URL}"
    echo

    # (Try to) Remove job artifacts older than 7 days ago
    function prune_job_git_ref() {
        local JOB_GIT_REF=$1
        git fetch --depth=1 origin ${JOB_GIT_REF} >/dev/null 2>&1
        [[ -z $(git log -1 --since='7 days ago' FETCH_HEAD) ]] || return 0
        echo_info "Deleting ${JOB_GIT_REF}..."
        git push --no-verify -f origin :${JOB_GIT_REF} >/dev/null 2>&1
    }
    while read -u3 JOB_GIT_REF; do
        prune_job_git_ref ${JOB_GIT_REF} || true
    done 3< <(git ls-remote origin "refs/jobs/*" | cut -f2)
}


function sf_ci_run_after_script() {
    sf_ci_run_after_script_upload_job_artifacts
}
