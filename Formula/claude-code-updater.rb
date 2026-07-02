class ClaudeCodeUpdater < Formula
  desc "Automatically update Claude Code from npm and show a macOS banner notification"
  homepage "https://github.com/schroneko/claude-code-updater"
  url "https://github.com/schroneko/claude-code-updater.git", tag: "v0.1.2"
  license "MIT"

  depends_on "jq"
  depends_on xcode: ["14.0", :build]

  def install
    app = buildpath/"Claude Code Updater.app"
    app_macos = app/"Contents/MacOS"
    app_resources = app/"Contents/Resources"

    app_macos.mkpath
    app_resources.mkpath

    system "swiftc", "Sources/ClaudeCodeUpdater/ClaudeCodeUpdater.swift", "-o", app_macos/"ClaudeCodeUpdater"
    cp "Resources/Info.plist", app/"Contents/Info.plist"
    cp "Resources/ClaudeIcon.icns", app_resources/"ClaudeIcon.icns"
    system "codesign", "--force", "--deep", "--sign", "-", app

    libexec.install app

    inreplace "bin/claude-code-updater-watch", "__APP_PATH__", libexec/"Claude Code Updater.app"
    bin.install "bin/claude-code-updater-watch"
  end

  service do
    run [opt_bin/"claude-code-updater-watch"]
    run_type :interval
    interval 60
    log_path var/"log/claude-code-updater.log"
    error_log_path var/"log/claude-code-updater.err.log"
  end

  test do
    assert_path_exists libexec/"Claude Code Updater.app/Contents/MacOS/ClaudeCodeUpdater"
    assert_match "claude-code-updater-watch", shell_output("#{bin}/claude-code-updater-watch --help")
  end
end
