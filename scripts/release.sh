#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
formula="$repo_root/Formula/claude-code-updater.rb"

cd "$repo_root"

branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" != "main" ]; then
  echo "release must run on main (current: $branch)" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "working tree is not clean" >&2
  exit 1
fi

git pull --ff-only

current_tag="$(sed -n 's/.*tag: "\(v[0-9][0-9.]*\)".*/\1/p' "$formula")"
if [ -z "$current_tag" ]; then
  echo "failed to read current tag from formula" >&2
  exit 1
fi

if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$current_tag^{commit}")" ]; then
  echo "no new commits since $current_tag"
  exit 0
fi

next_version="${1:-}"
if [ -z "$next_version" ]; then
  IFS=. read -r major minor patch <<<"${current_tag#v}"
  next_version="$major.$minor.$((patch + 1))"
fi
next_tag="v$next_version"

if git rev-parse -q --verify "refs/tags/$next_tag" >/dev/null; then
  echo "tag $next_tag already exists" >&2
  exit 1
fi

sed -i '' "s/tag: \"$current_tag\"/tag: \"$next_tag\"/" "$formula"
git add "$formula"
git commit -m "Bump formula to $next_tag"
git tag "$next_tag"
git push origin main "$next_tag"

export HOMEBREW_NO_AUTO_UPDATE=1
tap_dir="$(brew --repository schroneko/claude-code-updater)"
git -C "$tap_dir" pull --ff-only
brew upgrade claude-code-updater
brew services restart claude-code-updater

echo "released $next_tag"
