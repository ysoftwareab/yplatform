#!/usr/bin/env bash
set -euo pipefail

VSN=2.3.3

SRC_FILE=Formula/editorconfig-checker.rb.tpl

RB_FILE=${BASH_SOURCE[0]%.tpl}
# ID must be the PascalCase version of the RB_FILE
ID="$(basename "${RB_FILE%.rb}" | sed -r "s/(^|[^a-z])([a-z])/\U\2/g")" # EditorconfigChecker
BIN=editorconfig-checker

function get_asset_url() {
  OS=$1
  ARCH=$2

  echo "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/${VSN}/ec-${OS}-${ARCH}.tar.gz"
}

function get_asset_sha256() {
  OS=$1
  ARCH=$2

  curl -fqsSL "$(get_asset_url "${OS}" "${ARCH}")" | sha256sum | cut -d" " -f1
}

function get_bin() {
  OS=$1
  ARCH=$2

  echo "ec-${OS}-${ARCH}"
}

cat <<EOF > ${RB_FILE}
# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE})

class ${ID} < Formula
  version "${VSN}"
  bottle :unneeded

  if OS.mac?
    if Hardware::CPU.is_64_bit?
      url "$(get_asset_url darwin amd64)"
      sha256 "$(get_asset_sha256 darwin amd64)"
    else
      url "$(get_asset_url darwin 386)"
      sha256 "$(get_asset_sha256 darwin 386)"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "$(get_asset_url linux amd64)"
        sha256 "$(get_asset_sha256 linux amd64)"
      else
        url "$(get_asset_url linux 386)"
        sha256 "$(get_asset_sha256 linux 386)"
      end
    elsif Hardware::CPU.arm?
      if Hardware::CPU.is_64_bit?
        url "$(get_asset_url linux arm64)"
        sha256 "$(get_asset_sha256 linux arm64)"
      else
        url "$(get_asset_url linux arm)"
        sha256 "$(get_asset_sha256 linux arm)"
      end
    end
  end

  def install
    if OS.mac?
      if Hardware::CPU.is_64_bit?
        bin.install "$(get_bin darwin amd64)" => "${BIN}"
      else
        bin.install "$(get_bin darwin 386)" => "${BIN}"
      end
    elsif OS.linux?
      if Hardware::CPU.intel?
        if Hardware::CPU.is_64_bit?
          bin.install "$(get_bin linux amd64)" => "${BIN}"
        else
          bin.install "$(get_bin linux 386)" => "${BIN}"
        end
      elsif Hardware::CPU.arm?
        if Hardware::CPU.is_64_bit?
          bin.install "$(get_bin linux arm64)" => "${BIN}"
        else
          bin.install "$(get_bin linux arm)" => "${BIN}"
        end
      end
    end
  end

  test do
    system "#{bin}/${BIN} -v"
  end
end
EOF
