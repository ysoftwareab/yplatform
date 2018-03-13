#!/usr/bin/env bash

export T_AWS_IAM_INC_SH_DIR=${T_AWS_IAM_INC_SH_DIR:-$(dirname ${BASH_SOURCE[0]})}

function aws-iam-login() {
    [ $# -eq 1 ] || {
        echo >&2 "Usage: aws-iam-login <profilename>"
        return 1
    }

    AWS_PROFILE=$1

    aws configure get aws_access_key_id --profile ${AWS_PROFILE} >/dev/null || {
        echo >&2 "${AWS_PROFILE} profile is not configured."
        return 1
    }

    # Workarounds for the JavaScript SDK
    # - doesn't know about AWS_DEFAULT_PROFILE, but it does obey AWS_PROFILE
    # - doesn't know about the profile configuration's region, but it does obey AWS_REGION
    export AWS_DEFAULT_PROFILE=${AWS_PROFILE}
    export AWS_DEFAULT_REGION=$(aws configure get region --profile ${AWS_PROFILE})
    export AWS_PROFILE
    export AWS_REGION=${AWS_DEFAULT_REGION}
    export AWS_ROLE_ARN=$(aws configure get role_arn --profile ${AWS_PROFILE})

    unset AWS_SECRET_ACCESS_KEY
    unset AWS_ACCESS_KEY_ID
    unset AWS_SESSION_TOKEN

    echo "${AWS_PROFILE} AWS profile is now in use."
    aws configure list # login and obtain a session token

    CREDENTIALS_TEMP=$(mktemp)

    ${T_AWS_IAM_INC_SH_DIR}/aws-get-cli-sts > ${CREDENTIALS_TEMP}
    source ${CREDENTIALS_TEMP}

    rm -f ${CREDENTIALS_TEMP}
}

function _aws_profile_completer() {
    local WORD=${COMP_WORDS[COMP_CWORD]}
    local AWS_SHARED_CREDENTIALS_FILE=${AWS_SHARED_CREDENTIALS_FILE:-~/.aws/credentials}
    local AWS_PROFILES="$(grep "^\[" ${AWS_SHARED_CREDENTIALS_FILE} | xargs -I{} expr {} : "\[\(.*\)\]")"
    COMPREPLY=($(compgen -W "${AWS_PROFILES}" -- "${WORD}"))
}

complete -F _aws_profile_completer aws-iam-login
