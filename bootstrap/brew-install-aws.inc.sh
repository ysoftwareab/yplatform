#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:=} != "true" ]] || {
    # https://github.com/actions/virtual-environments/commit/0fa2247a898625b8020d8dfb1dc4a54ddb2b256c
    # Github Actions CI already installs awscli via pkg,
    # which will make 'brew install awscli' to fail when linking.
    # See https://github.com/rokmoln/support-firecloud/runs/1291359454
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
brew_install_one_if awscli "aws --version 2>&1 | head -1" "^aws-cli/2\."
# see https://github.com/Homebrew/linuxbrew-core/issues/21062
# brew uninstall awscli && brew install awscli
aws configure set s3.signature_version s3v4
echo_done
