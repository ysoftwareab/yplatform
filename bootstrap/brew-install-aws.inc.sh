#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:=} != "true" ]] || {
    # https://github.com/actions/virtual-environments/commit/0fa2247a898625b8020d8dfb1dc4a54ddb2b256c
    # Github Actions CI already installs awscli via pkg,
    # which will make 'brew install awscli' to fail when linking.
    # See https://github.com/ysoftwareab/yplatform/runs/1291359454
    pkgutil --pkgs | grep -q "^com\.amazon\.aws\.cli2" && HAS_AWSCLI_PKG=true || HAS_AWSCLI_PKG=false
    [[ "${HAS_AWSCLI_PKG}" = "false" ]] || (
        ls -la /usr/local/bin/aws
        ls -la /usr/local/bin/aws_completer

        cd /usr/local
        cat aws-cli/.install-metadata
        # delete e.g. /usr/local/bin/aws
        cat aws-cli/.install-metadata | xargs -L1 sudo rm -f
        sudo rm -rf aws-cli # faster than the two lines below
        # pkgutil --only-files --files com.amazon.aws.cli2 | xargs -L1 sudo rm -f
        # pkgutil --only-dirs --files com.amazon.aws.cli2 | /usr/bin/tail -r | xargs -L1 sudo rmdir

        sudo pkgutil --forget com.amazon.aws.cli2
    )
    unset HAS_AWSCLI_PKG
}


echo_do "brew: Installing AWS utils..."

brew_install_one_unless awscli "aws --version 2>&1 | head -1" "^aws-cli/2\." || {
    # Possible error on CircleCI, Github Actions (ubuntu 18.04)
    #
    # The conflict is caused by:
    # The user requested botocore 2.0.0.dev129 (from https://github.com/boto/botocore/zipball/v2#egg=botocore)
    # awscli 2.2.13 depends on botocore==2.0.0dev121
    #
    # Workaround: bypass homebrew, run official install
    # see https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

    EXIT_STATUS=$?
    # for convenience, we only support Linux for now
    [[ "${OS_SHORT}" = "linux" ]] || exit ${EXIT_STATUS}
    echo_warn "Falling back to installing AWS CLI outside Homebrew..."

    # AWSCLI_VSN="$(brew info --json=v1 awscli | jq -r ".[0].versions.stable")"
    AWSCLI_VSN="$(
        brew info --json=v1 ${YP_DIR}/Formula/patch-lib/awscli.rb | \
            jq -r ".[0].versions.stable")"

    AWSCLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWSCLI_VSN}.zip"
    echo_do "Installing AWS CLI ${AWSCLI_VSN}..."
    echo_info "AWSCLI_URL=${AWSCLI_URL}"
    (
        cd $(mktemp -d -t yplatform.XXXXXXXXXX)
        curl -qfsSL -o awscliv2.zip ${AWSCLI_URL}
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip
    )
    echo_done
}

# see https://github.com/Homebrew/linuxbrew-core/issues/21062
# brew uninstall awscli && brew install awscli

aws configure set s3.signature_version s3v4
echo_done
