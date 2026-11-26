# WP Repo Standard

A Claude Code plugin that sets up WordPress plugin and theme repositories the same way every time: automatic versioned releases, a deploy workflow with an on/off switch, a "linked issue" check, Dependabot and a protected `main`, where every change goes issue → branch → pull request → squash merge.

The standard itself lives in [wpgenius/wordpress-plugin-boilerplate](https://github.com/wpgenius/wordpress-plugin-boilerplate). Each version of this plugin is pinned to one reviewed commit of it, checked by SHA on download. Improvements to the boilerplate reach you with the next plugin update.

## Commands

| Command | What it does |
|---|---|
| `/wp-repo-standard:adopt [path]` | Brings an existing plugin or theme repo up to the standard. It audits the repo, asks one round of questions, opens one issue per change, adds the files on a branch and opens a single PR. Code restructuring is only proposed, never done without your yes. |
| `/wp-repo-standard:new [name]` | Starts a new plugin from the boilerplate: renames everything, resets the version to 1.0.0, creates the GitHub repo, protects `main` and pushes, so the first release is v1.0.0. |
| `/wp-repo-standard:submit [path]` | Gets a plugin ready for the WordPress.org directory and through review: audits the code, readme, licences and package against what reviewers flag, runs the repo's pre-submission checks, fixes findings through issues and one PR, says what to upload and drafts replies to review emails, then sets up WordPress.org deploys after approval. |

Both ask before anything outward-facing: creating a repo, changing GitHub settings, creating a deploy key, opening or merging a PR.

## What a repo gets

- `.gitignore`, and `.distignore`, which decides what ships.
- **Automatic releases** (`release.yml`): each merge to `main` that changes the plugin zip bumps the version (patch, or minor/major by label), writes it into the plugin header (or `style.css`) and `readme.txt` with a changelog built from the closed issues, tags it and publishes a GitHub release with the zip.
- **Deploys** (`deploy.yml`) to FTPS, SSH or WordPress.org, off until the repo variable `DEPLOY_ENABLED` is `true`.
- **Linked issue check**: a PR must close an issue. You can switch it off per repo (`REQUIRE_LINKED_ISSUE=false`); the changelog then uses PR titles.
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

## Data and network use

The plugin has no server of its own and collects or stores no personal data. Nothing is sent to WPGenius unless you agree to a problem report (below). While it works on your repo, it contacts only these services:

| Service | What for | What is sent |
|---|---|---|
| **GitHub** (`github.com`, through `git` and the GitHub CLI) | Download the public boilerplate; read the repo's settings; create the repo, issues, PRs, labels, the ruleset and the release deploy key; push the branch | Your repo's code and the issue and PR text, to your own GitHub repo, signed in as you. Every outward step is confirmed with you first. |
| **WordPress.org** (`api.wordpress.org`) | Look up the latest WordPress version, to check `readme.txt` "Tested up to" | Nothing about you or your repo (a plain public request) |
| **Packagist and npm** | Only if you add the optional tooling group: `composer install` and `npm install` download the dev tools | The package names in `composer.json` and `package.json` |

**Problem reports:** when a command hits a problem in this plugin or the standard, it ends by showing you a short report (plugin version, pinned standard, shell and OS, what failed and the fix that worked) with nothing that identifies your project. Only with your yes does it open an issue on [wpgenius/wp-repo-standard](https://github.com/wpgenius/wp-repo-standard/issues), as you. Maintainers can set `WP_REPO_STANDARD_MAINTAINER_SESSION` to the name of their maintenance Claude session to get reports there instead.

Deploys (FTPS, SSH, WordPress.org SVN) run later in your repo's GitHub Actions, not in this plugin, and stay off until you turn them on.

## Use your own standard

Fork the boilerplate (keep the fork public), change it, and set `REPO_STANDARD_SOURCE=your-org/your-boilerplate` and `REPO_STANDARD_SHA=<full commit SHA>` in your environment. The commands then use that commit of your fork as the standard.

## Contributing

Issues and pull requests: [wpgenius/wp-repo-standard](https://github.com/wpgenius/wp-repo-standard). See the repo's README for how changes are released.

## License

[GPL-3.0-or-later](LICENSE)
