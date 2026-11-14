#!/usr/bin/env bash
# Helpers shared by audit.sh and package-preview.sh. Sourced, not run.
#
# These mirror the packaging rules of the standard's .github/scripts/lib.sh
# (wordpress-plugin-boilerplate), kept here so this plugin never runs code it
# downloaded. If the boilerplate changes how it finds the main file or builds
# the zip, update these too.

# Prints the main file in the repo root: the .php file with a "Plugin Name:"
# header, or style.css with "Theme Name:". Returns 1 if there is neither.
main_plugin_file() {
	local f
	for f in *.php; do
		[ -f "$f" ] || continue
		if head -n 30 "$f" | grep -qiE '^[[:space:]/*#@]*Plugin Name:'; then
			echo "$f"
			return 0
		fi
	done
	if [ -f style.css ] && head -n 30 style.css | grep -qiE '^[[:space:]/*#@]*Theme Name:'; then
		echo "style.css"
		return 0
	fi
	return 1
}

# Prints the "Version:" value from a file's header.
header_version() {
	head -n 30 "$1" | sed -nE 's/^[[:space:]/*#@]*Version:[[:space:]]*([^[:space:]]+).*/\1/Ip' | head -n 1
}

# Copies the current folder to $1 without .git and without what .distignore excludes.
build_package() {
	local dest="$1"
	mkdir -p "$dest"
	rsync --archive --delete --exclude='.git' --exclude-from='.distignore' ./ "$dest/"
	if find "$dest" -type l | grep -q .; then
		echo "Symlinks are not allowed in the package:" >&2
		find "$dest" -type l >&2
		return 1
	fi
}
