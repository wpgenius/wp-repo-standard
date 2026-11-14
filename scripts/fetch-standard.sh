#!/usr/bin/env bash
# Downloads the current repo standard: a shallow copy of the boilerplate's main.
# The boilerplate is the single source of truth, so nothing is copied into this plugin.
# The files are only read and copied into the user's repo; nothing in them is run.
#
#   fetch-standard.sh [dest]        prints the folder it wrote
#
# REPO_STANDARD_SOURCE overrides the source repo (owner/name, public on GitHub).
set -euo pipefail

src=${REPO_STANDARD_SOURCE:-wpgenius/wordpress-plugin-boilerplate}
dest=${1:-"$(mktemp -d)/standard"}

[[ "$src" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "REPO_STANDARD_SOURCE must be owner/name" >&2; exit 1; }
[ ! -e "$dest" ] || { echo "$dest already exists; pass a new folder" >&2; exit 1; }

GIT_TERMINAL_PROMPT=0 git clone --depth 1 --quiet "https://github.com/$src.git" "$dest" \
	|| { echo "Could not download https://github.com/$src (it must be a public repo)" >&2; exit 1; }
git -C "$dest" log -1 --format="Standard: $src @ %h \"%s\" (%cs)" >&2
echo "$dest"
