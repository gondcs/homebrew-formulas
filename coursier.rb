require 'formula'

# adapted from https://github.com/paulp/homebrew-extras/blob/8184f9a962ce0758f4cf7a07b702bc1c3d16dfaa/coursier.rb

class Coursier < Formula
  desc "Coursier launcher."
  homepage "https://get-coursier.io"
  version "2.0.0-RC6-20"
  url "https://github.com/coursier/coursier/releases/download/v2.0.0-RC6-20/cs-x86_64-apple-darwin"
  sha256 "2f77f3205023a2ab59d77c76476195168132fa1cc1532b2aeddc2ddddb12f9f7"
  bottle :unneeded

  # https://stackoverflow.com/questions/10665072/homebrew-formula-download-two-url-packages/26744954#26744954
  resource "jar-launcher" do
    url "https://github.com/coursier/coursier/releases/download/v2.0.0-RC6-20/coursier"
    sha256 "d309b5d87bc4486b238d0db47d89fe8e4c4d2e86c4fd6588f131c8b60754b999"
  end

  option "without-zsh-completions", "Disable zsh completion installation"

  depends_on :java => "1.8+"

  def install
    unless build.without? "zsh-completion"
      FileUtils.mkdir_p "completions/zsh"
      system "bash", "-c", "bash ./coursier --completions zsh > completions/zsh/_coursier"
      zsh_completion.install "completions/zsh/_coursier"
    end

    bin.install 'cs-x86_64-apple-darwin' => "cs"
    resource("jar-launcher").stage { bin.install "coursier" }
  end

  test do
    ENV["COURSIER_CACHE"] = "#{testpath}/cache"

    output = shell_output("#{bin}/cs launch io.get-coursier:echo:1.0.2 -- foo")
    assert_equal ["foo\n"], output.lines

    jar_output = shell_output("#{bin}/coursier launch io.get-coursier:echo:1.0.2 -- foo")
    assert_equal ["foo\n"], jar_output.lines
  end
end
