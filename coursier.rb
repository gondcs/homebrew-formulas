# adapted from https://github.com/paulp/homebrew-extras/blob/8184f9a962ce0758f4cf7a07b702bc1c3d16dfaa/coursier.rb
class Coursier < Formula
  desc "Launcher for Coursier"
  homepage "https://get-coursier.io"
  url "https://github.com/coursier/coursier/releases/download/v2.0.11/cs-x86_64-apple-darwin"
  version "2.0.11"
  sha256 "30ed0b9030869edfb8d164fda38b2175b852c3890c986e557843cd2cac3b7c04"
  bottle :unneeded

  option "without-zsh-completions", "Disable zsh completion installation"

  # https://stackoverflow.com/questions/10665072/homebrew-formula-download-two-url-packages/26744954#26744954
  resource "jar-launcher" do
    url "https://github.com/coursier/coursier/releases/download/v2.0.11/coursier"
    sha256 "8e62893c13f33bc0e25ee2681d689b8a791a0339de5dd48af394907c9da75a18"
  end

  depends_on java: "1.8+" if MacOS.version < :catalina
  depends_on "openjdk" if MacOS.version >= :catalina

  def install
    bin.install "cs-x86_64-apple-darwin" => "cs"
    resource("jar-launcher").stage { bin.install "coursier" }

    unless build.without? "zsh-completions"
      chmod 0555, bin/"coursier"
      output = Utils.safe_popen_read("#{bin}/coursier --completions zsh")
      (zsh_completion/"_coursier").write output
    end
  end

  test do
    ENV["COURSIER_CACHE"] = "#{testpath}/cache"

    output = shell_output("#{bin}/cs launch io.get-coursier:echo:1.0.2 -- foo")
    assert_equal ["foo\n"], output.lines

    jar_output = shell_output("#{bin}/coursier launch io.get-coursier:echo:1.0.2 -- foo")
    assert_equal ["foo\n"], jar_output.lines
  end
end
