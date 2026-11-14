#!/usr/bin/env bash
# Downloads the current repo standard: a shallow copy of the boilerplate's main.
# The boilerplate is the single source of truth, so nothing is copied into this plugin.
#
#   fetch-standard.sh [dest]        prints the folder it wrote
#
# REPO_STANDARD_SOURCE overrides the source repo (owner/name).
# Uses the GitHub CLI when it is signed in (private forks work), otherwise plain git over HTTPS.
set -euo pipefail

src=${REPO_STANDARD_SOURCE:-wpgenius/wordpress-plugin-boilerplate}
dest=${1:-"$(mktemp -d)/standard"}

[[ "$src" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "REPO_STANDARD_SOURCE must be owner/name" >&2; exit 1; }
[ ! -e "$dest" ] || { echo "$dest already exists; pass a new folder" >&2; exit 1; }

if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
	gh repo clone "$src" "$dest" -- --depth 1 --quiet
else
	git clone --depth 1 --quiet "https://github.com/$src.git" "$dest"
fi
git -C "$dest" log -1 --format="Standard: $src @ %h \"%s\" (%cs)" >&2
echo "$dest"
