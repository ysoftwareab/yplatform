#!/usr/bin/env bash
#!/usr/bin/env zsh

function yp::aws-iam-login() {
    [[ $# -eq 1 ]] || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Usage: yp::aws-iam-login <profilename>"
        return 1
    }

    AWS_PROFILE=$1

    aws configure get aws_access_key_id --profile ${AWS_PROFILE} >/dev/null || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] ${AWS_PROFILE} profile is not configured."
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

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN

    >&2 echo "$(date +"%H:%M:%S")" "[INFO] ${AWS_PROFILE} AWS profile is now in use."
    aws configure list # login and obtain a session token

    CREDENTIALS_TEMP=$(mktemp -t yplatform.XXXXXXXXXX)

    ${GLOBAL_YP_DIR}/bin/aws-get-cli-sts > ${CREDENTIALS_TEMP}
    source ${CREDENTIALS_TEMP}

    rm -f ${CREDENTIALS_TEMP}

    [[ -n "${AWS_ACCESS_KEY_ID}" ]] || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] No AWS_ACCESS_KEY_ID in the environment. Something went wrong."
        return 1
    }

    [[ -n "${AWS_SECRET_ACCESS_KEY}" ]] || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] No AWS_SECRET_ACCESS_KEY in the environment. Something went wrong."
        return 1
    }

    [[ -n "${AWS_SESSION_TOKEN}" ]] || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] No AWS_SESSION_TOKEN in the environment. Something went wrong."
        return 1
    }
}

function yp::aws-iam-login-ns() {
    [[ $# -eq 2 ]] || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Usage: aws-iam-login-ns <profilename> <namespace>"
        return 1
    }

    local LOCAL_AWS_PROFILE="${AWS_PROFILE:-}"
    local NS_AWS_PROFILE=$1
    local NS=$2

    yp::aws-iam-login ${NS_AWS_PROFILE}

    declare -x ${NS}_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    declare -x ${NS}_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    declare -x ${NS}_AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}

    if [[ -n "${LOCAL_AWS_PROFILE:-}" ]]; then
        yp::aws-iam-login ${LOCAL_AWS_PROFILE}
    else
        >&2 echo
        >&2 echo "$(date +"%H:%M:%S")" \
            "[WARN] You are logged in as ${NS_AWS_PROFILE} in your CURRENT environment as well."
    fi

    >&2 echo
    >&2 echo "$(date +"%H:%M:%S")" \
        "[INFO] Credentials for ${NS_AWS_PROFILE} are now stored in ${NS}_ environment variables."
}

function yp::_aws-iam-login_completer() {
    local WORD=${COMP_WORDS[COMP_CWORD]}
    local AWS_SHARED_CREDENTIALS_FILE=${AWS_SHARED_CREDENTIALS_FILE:-${HOME}/.aws/credentials}
    local AWS_PROFILES="$(grep "^\[" ${AWS_SHARED_CREDENTIALS_FILE} | sed "s/\(^\[\|\]$\)//g")"
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${AWS_PROFILES}" -- "${WORD}"))
}

complete -F yp::_aws-iam-login_completer yp::aws-iam-login
complete -F yp::_aws-iam-login_completer yp::aws-iam-login-ns
