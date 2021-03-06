# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (Formula/editorconfig-checker.rb.tpl)

class EditorconfigChecker < Formula
  version "2.3.3"
  bottle :unneeded

  on_macos do
    if Hardware::CPU.is_64_bit?
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-darwin-amd64.tar.gz"
      sha256 "3057c66e3da4efe4d02e99ea685a3af0e9da16ee59c49f84511ffea3243d03f4"
    else
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-darwin-386.tar.gz"
      sha256 "885899b336a159922b5008dbfc656143e1006a609535f8b7702f9e0f823e0f45"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-linux-amd64.tar.gz"
        sha256 "a9aade95018ee9c5c43e381d5ab1f69ba1ebd839b33c23afcf4d6bc86736a89a"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-linux-386.tar.gz"
        sha256 "ca66f38244d7f8732df612fba47205826690b37d2fd39ac58550c8818bac546d"
      end
    elsif Hardware::CPU.arm?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-linux-arm64.tar.gz"
        sha256 "8d20401796fa0ea4d7479af6f56f033e52ceeb6208387b2046536e7cccc2ea3a"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.3/ec-linux-arm.tar.gz"
        sha256 "c990a1ed55339aef69832d5bffd49b16f85be7e8fe64564c092209e3f02b8f85"
      end
    end
  end

  def install
    on_macos do
      if Hardware::CPU.is_64_bit?
        bin.install "ec-darwin-amd64" => "editorconfig-checker"
      else
        bin.install "ec-darwin-386" => "editorconfig-checker"
      end
    end

    on_linux do
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
