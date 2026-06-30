# Claude Code Updater

Claude Code Updater watches the npm package for Claude Code and installs the newest stable semver release as soon as it appears. After a successful update, it shows a macOS banner notification:

```text
Claude Code Updated.
Ver x.y.z installed.
```

The notification is sent by `Claude Code Updater.app`, a small menu-less macOS app bundled with this Homebrew formula.

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

```sh
claude-code-updater-watch
```

## Logs

The watcher writes its own log to:

```text
~/.local/state/claude-code-updater/run.log
```

Homebrew service logs are available at:

```text
$(brew --prefix)/var/log/claude-code-updater.log
$(brew --prefix)/var/log/claude-code-updater.err.log
```

## How It Works

1. Fetches `@anthropic-ai/claude-code` metadata from npm.
2. Selects the highest stable `x.y.z` version.
3. Waits until the Claude downloads manifest exists.
4. Runs the official installer:

```sh
curl -fsSL https://claude.ai/install.sh | bash -s -- x.y.z
```

5. Shows a macOS banner from `Claude Code Updater.app`.

## Uninstall

```sh
brew services stop claude-code-updater
brew uninstall claude-code-updater
brew untap schroneko/claude-code-updater
```

## License

MIT
