# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (editorconfig-checker.rb.tpl)

class EditorconfigChecker < Formula
  version "2.0.3"
  bottle :unneeded

  if OS.mac?
    if Hardware::CPU.is_64_bit?
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-darwin-amd64.tar.gz"
      sha256 "c6d646f8057eccde7ad85225fc5dd54a2e7124929a1b61d2f053c343102ed91e"
    else
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-darwin-386.tar.gz"
      sha256 "b58367263b45740d50733b4b4533c10c7434ddba5794609eb4c007dd1cb4bcfd"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-linux-amd64.tar.gz"
        sha256 "8c61c1bfc82a219f87a700bc04f868bf04a7e9b8854cddae6a781405b3f2e7d5"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-linux-386.tar.gz"
        sha256 "ade995b1c828564f1a3c9694ac15a52cc4c8e57d7a0a559b423cf63b2ea90602"
      end
    elsif Hardware::CPU.arm?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-linux-arm64.tar.gz"
        sha256 "8010008c2109d8c168bb76248cc4e69aaa8843325fe199f9db4ac098f8f40e6b"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.0.3/ec-linux-arm.tar.gz"
        sha256 "281943af43a4455140ac4352abf2a423e5faad38ffcf5439f7b5105e4a4f7ce7"
      end
    end
  end

  def install
    if OS.mac?
      if Hardware::CPU.is_64_bit?
        bin.install "ec-darwin-amd64" => "editorconfig-checker"
      else
        bin.install "ec-darwin-386" => "editorconfig-checker"
      end
    elsif OS.linux?
      if Hardware::CPU.intel?
        if Hardware::CPU.is_64_bit?
          bin.install "ec-linux-amd64" => "editorconfig-checker"
        else
          bin.install "ec-linux-386" => "editorconfig-checker"
        end
      elsif Hardware::CPU.arm?
        if Hardware::CPU.is_64_bit?
          bin.install "ec-linux-arm64" => "editorconfig-checker"
        else
          bin.install "ec-linux-arm" => "editorconfig-checker"
        end
      end
    end
  end

  test do
    system "#{bin}/editorconfig-checker -v"
  end
end
