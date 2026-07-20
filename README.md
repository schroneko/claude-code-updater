# Claude Code Updater

Claude Code Updater watches the npm package for Claude Code and installs the newest stable semver release as soon as it appears. After a successful update, it shows a macOS banner notification:

```text
Claude Code Updated.
Ver x.y.z installed.
```

## Components

- `bin/claude-code-updater`: a zsh script that performs one update check per run. Homebrew installs it into `$(brew --prefix)/bin`, and the Homebrew service runs it every 60 seconds.
- `Sources/ClaudeCodeUpdater/ClaudeCodeUpdater.swift`: the source of `Claude Code Updater.app`, a small menu-less macOS app compiled by the formula at install time. The watcher launches it once per notification; the app posts the banner and quits a few seconds later. Clicking the banner just dismisses it.
- `Formula/claude-code-updater.rb`: the Homebrew formula. It builds the app with `swiftc`, ad-hoc signs it, installs the watcher, and defines the interval service. This repository doubles as its own Homebrew tap.
- `scripts/release.sh`: release automation. See the Release section.

## Requirements

- macOS
- Homebrew
- Xcode command line tools or Xcode
- Claude Code installed through the official installer

## Installation

```sh
brew tap schroneko/claude-code-updater https://github.com/schroneko/claude-code-updater
brew install claude-code-updater
brew services start claude-code-updater
```

The service checks npm every 60 seconds.

## Manual Run

The watcher is a normal command, so a single check can be run by hand:

```sh
claude-code-updater
```

A run exits quietly when Claude Code is already up to date. `claude-code-updater --help` prints a short description.

## State and Logs

The watcher keeps its state under `~/.local/state/claude-code-updater/` (or `$XDG_STATE_HOME/claude-code-updater/`):

- `version`: the version the watcher considers installed
- `run.log`: the watcher's own log, including installer output
- `lock/`: a lock directory that prevents overlapping runs

Homebrew service logs are available at:

```text
$(brew --prefix)/var/log/claude-code-updater.log
$(brew --prefix)/var/log/claude-code-updater.err.log
```

## How It Works

Each run of `claude-code-updater`:

1. Acquires the lock, removing a stale one first if a previous run died.
2. Fetches abbreviated `@anthropic-ai/claude-code` metadata from npm and selects the highest stable `x.y.z` version.
3. Compares it with the recorded state. On the first run the state is initialized from `claude --version` and nothing is installed.
4. Waits until the release manifest exists at `https://downloads.claude.ai/claude-code-releases/x.y.z/manifest.json`, because npm metadata can appear before the binaries are published.
5. Runs the official installer:

```sh
curl -fsSL https://claude.ai/install.sh | bash -s -- x.y.z
```

6. Records the new version and shows a macOS banner from `Claude Code Updater.app`. If the app is missing, it falls back to `osascript`. A failed install posts a failure banner instead and keeps the previous state so the next run retries.

All network calls use connect and total timeouts, so a hung npm or CDN endpoint cannot wedge the service.

## Release

The Homebrew formula builds from a git tag, so source changes on `main` are not delivered until the formula is bumped and a new tag is pushed. Run the release script to do all of it in one step:

```sh
scripts/release.sh
```

It bumps the formula to the next patch version, commits, tags, pushes `main` and the tag, then upgrades the local Homebrew install and restarts the service. Pass a version to override the patch bump:

```sh
scripts/release.sh 0.2.0
```

Documentation-only changes do not need a release, since the formula installs nothing from `README.md`.

## Uninstall

```sh
brew services stop claude-code-updater
brew uninstall claude-code-updater
brew untap schroneko/claude-code-updater
```

## License

MIT
