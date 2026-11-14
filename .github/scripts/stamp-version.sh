#!/usr/bin/env bash
# Writes a release into the repo: the version in wp-repo-standard/.claude-plugin/plugin.json and
# a new entry at the top of CHANGELOG.md.
#
#   stamp-version.sh X.Y.Z changelog-file
set -euo pipefail

version=${1:?usage: stamp-version.sh X.Y.Z changelog-file}
notes=${2:?usage: stamp-version.sh X.Y.Z changelog-file}
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "bad version '$version'" >&2; exit 1; }

manifest=wp-repo-standard/.claude-plugin/plugin.json
tmp=$(mktemp)
jq --tab --arg v "$version" '.version = $v' "$manifest" > "$tmp" && mv "$tmp" "$manifest"

# Insert the entry above the first existing "## " heading (or at the end).
ENTRY=$(printf '## %s (%s)\n\n%s\n' "$version" "$(date -u +%Y-%m-%d)" "$(cat "$notes")")
export ENTRY
awk '
	!done && /^## / { print ENVIRON["ENTRY"]; print ""; done = 1 }
	{ print }
	END { if (!done) { print ""; print ENVIRON["ENTRY"] } }
' CHANGELOG.md > "$tmp" && mv "$tmp" CHANGELOG.md
