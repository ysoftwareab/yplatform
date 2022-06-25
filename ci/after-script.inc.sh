#!/usr/bin/env bash
set -euo pipefail

function yp_ci_run_after_script_upload_job_artifacts() {
    [[ -f .artifacts ]] || {
        echo_skip "${FUNCNAME[0]}: No .artifacts found..."
        return 0
    }

    [[ -n "${YP_GH_TOKEN_DEPLOY:-}" ]] || {
        echo_skip "${FUNCNAME[0]}: No YP_GH_TOKEN_DEPLOY found..."
        return 0
    }

    echo_do "Uploading job artifacts..."

    local GIT_HASH=$(git rev-parse HEAD)
    local JOB_GIT_REF=refs/jobs/${YP_CI_JOB_ID}

    git checkout --orphan jobs/${YP_CI_JOB_ID}
    git ls-fi_YP_les -- "*/.gitignore" | \
        while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; rm -f "${NO_XARGS_R}"; done
    git reset -- .
    git ls-files -X .artifacts --other --ignored | \
        while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; git add -f "${NO_XARGS_R}"; done || \
        true

    [[ "${TRAVIS:-}" != "true" ]] || {
        # (Try to) Create log.sh-session
        local CURL_TRAVIS_API_HEADERS=(-H "travis-api-version: 3")
        [[ -z "${TRAVIS_API_TOKEN:-}" ]] || {
            CURL_TRAVIS_API_HEADERS+=(-H "authorization: token ${TRAVIS_API_TOKEN}")
        }
        touch log.sh-session
        exe curl -qfsSL \
            "${CURL_TRAVIS_API_HEADERS[@]}" \
            https://api.travis-ci.com/job/${TRAVIS_JOB_ID}/log | \
            jq -r '.content' >log.sh-session || true
        git add -f log.sh-session
    }

    # FIXME not working because logs are only available after the job is terminated
    # see https://github.community/t/how-to-see-the-full-log-while-a-workflow-is-in-progress/17455
    [[ "${YP_CI_PLATFORM:-}" != "github" ]] || {
        # (Try to) Create log.sh-session
        local CURL_GITHUB_API_HEADERS=(-H "accept: application/vnd.github.v3+json")
        CURL_GITHUB_API_HEADERS+=(-H "authorization: token ${YP_GH_TOKEN_DEPLOY}")
        touch log.sh-session
        exe curl -qfsSL \
            "${CURL_GITHUB_API_HEADERS[@]}" \
            https://api.github.com/repos/${YP_CI_REPO_SLUG}/actions/jobs/${YP_CI_JOB_ID}/logs >log.sh-session || true
        git add -f log.sh-session
    }

    # Create README.md
    cat <<-EOF >README.md
${JOB_GIT_REF}

# Job [${YP_CI_JOB_ID}](${YP_CI_JOB_URL})

## Artifacts

$(git ls-files | \
while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; echo "* [${NO_XARGS_R}](${NO_XARGS_R})"; done)

EOF
    git add -f README.md

    git commit -m "${YP_CI_JOB_ID}"
    local JOB_GIT_HASH=$(git rev-parse HEAD)

    # Upload to git refs/job/<job_id>
    git push --no-verify -f https://${YP_GH_TOKEN_DEPLOY}@github.com/${YP_CI_REPO_SLUG}.git HEAD:${JOB_GIT_REF} || true


    git checkout -f - || git checkout -f ${GIT_HASH}
    # restore files added above 'git ls-files -X .artifacts --other --ignored | ...'
    git diff --name-only --diff-filter=A ..${JOB_GIT_HASH} | \
        while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; \
        git checkout ${JOB_GIT_HASH} -- "${NO_XARGS_R}"; done
    git reset

    echo_done

    local JOB_GITHUB_UI_URL=https://github.com/${YP_CI_REPO_SLUG}/tree/${JOB_GIT_HASH}

    echo
    echo_info "View job artifacts on Github: ${JOB_GITHUB_UI_URL}"
    echo

    # (Try to) Remove job artifacts older than 7 days ago
    function prune_job_git_ref() {
        local JOB_GIT_REF=$1
        [[ -n $(git log -1 --since="7 days ago" "${JOB_GIT_REF}") ]] || {
            echo_info "Deleting ${JOB_GIT_REF}..."
            git push --no-verify -f origin :${JOB_GIT_REF} >/dev/null 2>&1
        }
    }
    PRUNE=
    if git fetch --depth=1 origin refs/jobs/prune; then
        [[ -n $(git log -1 --since="7 days ago" FETCH_HEAD) ]] || PRUNE=true
    else
        PRUNE=true
    fi
    if [[ "${PRUNE}" = "true" ]]; then
        echo_do "Pruning remote refs/jobs/*..."
        git fetch --depth=1 --refmap="" origin "+refs/jobs/*:refs/jobs/*" >/dev/null 2>&1
        while read -r -u3 JOB_GIT_REF; do
            prune_job_git_ref ${JOB_GIT_REF} || true
        done 3< <(git ls-remote origin "refs/jobs/*" | cut -f2)
        echo_done
        git push --no-verify -f \
            https://${YP_GH_TOKEN_DEPLOY}@github.com/${YP_CI_REPO_SLUG}.git ${JOB_GIT_HASH}:refs/jobs/prune || true
            true
    else
        echo_skip "Pruning remote refs/jobs/*..."
    fi
    unset PRUNE
}


function yp_ci_run_after_script() {
    yp_ci_run_after_script_upload_job_artifacts
}
