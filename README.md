# wp-repo-standard

Source of the **WP Repo Standard** Claude Code plugin: `/wp-repo-standard:adopt` brings an existing WordPress plugin or theme repo up to the [wordpress-plugin-boilerplate](https://github.com/wpgenius/wordpress-plugin-boilerplate) standard, `/wp-repo-standard:new` starts a new plugin from it, and `/wp-repo-standard:submit` gets a plugin through WordPress.org review.

**What the plugin does, how to install it and what it needs: [wp-repo-standard/README.md](wp-repo-standard/README.md).**

```
/plugin marketplace add wpgenius/wp-repo-standard
/plugin install wp-repo-standard@wpgenius
```

## Layout

| Path | What |
|---|---|
| `wp-repo-standard/` | The plugin: `.claude-plugin/plugin.json`, the icon, `skills/`, `rules.md`, its README and LICENSE. This folder is what the Claude plugin directory reviews and what Claude Code installs. |
| `.claude-plugin/marketplace.json` | Lets people install straight from this repo (`source: ./wp-repo-standard`). |
| `.github/` | CI, the release workflow and its scripts. Not part of the plugin. |
| `CHANGELOG.md` | Written by the release workflow. |

The plugin folder holds only Markdown, JSON and images: the plugin directory accepts scripts only from Verified organizations, and CI enforces that. Commands the skills need are written as steps in the skills, not as script files.

## Changing it

Every change starts with an issue. Open a PR that closes it (`Closes #N`); CI and the linked-issue check must pass, then squash-merge.

Merges that change anything in `wp-repo-standard/` are released automatically: the version in `wp-repo-standard/.claude-plugin/plugin.json` is bumped (patch, or minor/major with a `release:minor`/`release:major` label), `CHANGELOG.md` gets an entry, and a GitHub release is published. Other changes make no release. The plugin directory picks up new commits and reviews each new version before it goes live.

Test locally without installing:

```bash
claude --plugin-dir wp-repo-standard
```

## License

[GPL-3.0-or-later](LICENSE)
