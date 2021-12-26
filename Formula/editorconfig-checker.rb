# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (Formula/editorconfig-checker.rb.tpl)

class EditorconfigChecker < Formula
  version "2.4.0"
  bottle :unneeded

  on_macos do
    if Hardware::CPU.is_64_bit?
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-darwin-amd64.tar.gz"
      sha256 "28fafcba28df8249e3f07edc22af2337258973bce29f872a2f6eab48335206fe"
    else
      url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-darwin-386.tar.gz"
      sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-linux-amd64.tar.gz"
        sha256 "91796ba6ae1d7c12c1dc92c081e41adc66a073839f2131c540d74b7bcc546b1d"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-linux-386.tar.gz"
        sha256 "d9246e71d7b56bb517540b7037b9eb5b547013ded3e0f281a144851e87dc888b"
      end
    elsif Hardware::CPU.arm?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-linux-arm64.tar.gz"
        sha256 "7bb169c55ddaff45a4429266c80d3ba5d3e3dace733195bdb7066646a864ae0b"
      else
        url "https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.4.0/ec-linux-arm.tar.gz"
        sha256 "1dd390e4e8f843418e00be4154a5a01e835623d737e9227c649f1cfedb8fd6b7"
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
