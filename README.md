# WP Repo Standard

A Claude Code plugin that sets up WordPress plugin and theme repositories the same way every time: automatic versioned releases, a deploy workflow with an on/off switch, a "linked issue" check, Dependabot and a protected `main`, where every change goes issue → branch → pull request → squash merge.

The standard itself lives in [wpgenius/wordpress-plugin-boilerplate](https://github.com/wpgenius/wordpress-plugin-boilerplate). Each run downloads its latest `main`, so improvements to the boilerplate reach you without updating this plugin.

## Commands

| Command | What it does |
|---|---|
| `/wp-repo-standard:adopt [path]` | Brings an existing plugin or theme repo up to the standard. It audits the repo, asks one round of questions, opens one issue per change, adds the files on a branch and opens a single PR. Code restructuring is only proposed, never done without your yes. |
| `/wp-repo-standard:new [name]` | Starts a new plugin from the boilerplate: renames everything, resets the version to 1.0.0, creates the GitHub repo, protects `main` and pushes, so the first release is v1.0.0. |

Both ask before anything outward-facing: creating a repo, changing GitHub settings, creating a deploy key, opening or merging a PR.

## What a repo gets

- `.gitignore`, and `.distignore`, which decides what ships.
- **Automatic releases** (`release.yml`): each merge to `main` that changes the plugin zip bumps the version (patch, or minor/major by label), writes it into the plugin header (or `style.css`) and `readme.txt` with a changelog built from the closed issues, tags it and publishes a GitHub release with the zip.
- **Deploys** (`deploy.yml`) to FTPS, SSH or WordPress.org, off until the repo variable `DEPLOY_ENABLED` is `true`.
- **Linked issue check**: a PR must close an issue.
- **Dependabot** for GitHub Actions.
- **GitHub settings** (`bin/setup-github.sh`): squash-only merges, release labels, a release deploy key and a "Protect main" ruleset.
- Optional: CI with PHPCS, PHPStan, unit tests and Plugin Check, community files, a WordPress Playground demo.

## Install

From the Claude plugin directory, or in Claude Code:

```
/plugin marketplace add wpgenius/wp-repo-standard
/plugin install wp-repo-standard@wpgenius
```

Updates: `/plugin marketplace update wpgenius`, or turn on auto-update for the marketplace in `/plugin`.

## Requirements

- `git` and `bash`.
- The [GitHub CLI](https://cli.github.com) signed in (`gh auth login`) as an admin of the repo, for the GitHub settings. Without it (for example in a cloud session) the commands still do the file work and the PR, then give you the one command to run on your own computer: `bin/setup-github.sh OWNER/REPO`.
- `php` for the syntax checks; Composer and npm only if you add the tooling.

## Use your own standard

Fork the boilerplate (keep the fork public), change it, and set `REPO_STANDARD_SOURCE=your-org/your-boilerplate` in your environment. The commands then use your fork as the standard.

## Contributing

Every change starts with an issue. Open a PR that closes it (`Closes #N`). Merges to `main` that change the plugin (`skills/`, `scripts/`, `rules.md`, `.claude-plugin/`) are released automatically: the version in `.claude-plugin/plugin.json` is bumped, `CHANGELOG.md` is updated and a GitHub release is published. Docs- and CI-only changes make no release.

Test locally without installing:

```bash
claude --plugin-dir .
```

## License

[GPL-3.0-or-later](LICENSE)
