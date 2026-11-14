# Repo standard: shared rules

Both `/wp-repo-standard:new` and `/wp-repo-standard:adopt` follow these rules.
**The user's own instructions win:** if their CLAUDE.md or messages say otherwise, follow them.

## Source of the standard

The standard lives in one place: **wpgenius/wordpress-plugin-boilerplate**, branch `main`. Every run downloads it fresh, so changes to the boilerplate reach every user without a new version of this plugin. Never copy standard files from memory or from this plugin.

If the user keeps their own public fork of the boilerplate as their standard, they set `REPO_STANDARD_SOURCE=owner/name` in their environment; the download below uses it.

The downloaded files are only **read and copied** into the user's repo. Never run a script from the download itself. The only scripts you run are the user's own copies inside their repo, as each command describes: `bin/setup-github.sh` (with their yes) and, in `/wp-repo-standard:new`, `bin/rename.sh`.

## Shared steps

These run on local files only: no login is needed, and GitHub is reached only by `git clone` of the public standard and by the `gh` commands each command lists.

### Download the standard
```bash
STD="$(mktemp -d)/standard"
git clone --depth 1 --quiet "https://github.com/${REPO_STANDARD_SOURCE:-wpgenius/wordpress-plugin-boilerplate}.git" "$STD" \
  && git -C "$STD" log -1 --format='Standard: %h "%s" (%cs)'
```
Keep `$STD` for the rest of the run. If the clone fails, say so and stop: the source must be a public GitHub repo.

### Merge an ignore file
For `.gitignore` and `.distignore`: the result is the standard's file unchanged, followed by the rules from the repo's own file that the standard doesn't already have. Nothing from either side is dropped.
```bash
F=.distignore   # then the same for .gitignore
extra=$( [ -f "$F" ] && grep -vE '^[[:space:]]*(#|$)' "$F" | sed 's/[[:space:]]*$//' | awk '!seen[$0]++' | grep -vxF -f <(sed 's/[[:space:]]*$//' "$STD/$F") )
{ cat "$STD/$F"; if [ -n "$extra" ]; then printf '\n# --------------------------------------------------\n# Project-specific (kept from this repo)\n# --------------------------------------------------\n%s\n' "$extra"; fi; } > "$F.new" && mv "$F.new" "$F"
```
Then read the "Project-specific" block. Remove rules that duplicate or fight the standard (for example `!vendor/`), and keep the genuinely project-specific ones. Watch for unanchored rules that hide runtime files, such as `vendor/`, which also matches `assets/vendor/`; anchor them (`/vendor/`).

The standard part stays unchanged, with one exception: a plugin whose blocks are plain JS with no build step comments out `/blocks` in `.distignore` (see adopt step 4). For `.distignore` this decides what ships, so always check the package preview afterwards.

### Preview the package
Lists exactly what the release zip will contain. Like CI, it starts from what git would commit (tracked files plus new files that aren't git-ignored), then applies `.distignore`:
```bash
P=$(mktemp -d)
git ls-files -z --cached --others --exclude-standard |
  while IFS= read -r -d '' f; do [ -e "$f" ] || [ -L "$f" ] && printf '%s\0' "$f"; done |
  rsync -a --from0 --files-from=- ./ "$P/src/"
rsync -a --exclude=.git --exclude-from="$P/src/.distignore" "$P/src/" "$P/pkg/"
(cd "$P/pkg" && find . -type f | sed 's#^\./##' | sort); find "$P/pkg" -type l
```
Check the list, and tell the user what you find:
- **The main file is in it:** the root `.php` file with a `Plugin Name:` header, or `style.css` with `Theme Name:` for a theme.
- **Nothing dev-only ships:** dotfiles, `node_modules/`, `vendor/bin/`, `tests/`, block sources, `*.zip`, `*.log`, `*.sql`, `.env*`, `composer.*`, `package*.json`, `phpcs.xml*`, `phpunit.xml*`, `docker-compose*.yml`.
- **Everything needed at runtime ships:** for example `build/`, `vendor/` for runtime dependencies, `languages/`.
- **No symlinks:** the last command must print nothing; the release refuses symlinks.

## Where it runs

The file work (audit, adding files, branch, commits, PR) needs only `git`. The GitHub settings (step "GitHub settings" in each command, `bin/setup-github.sh`) need the GitHub CLI signed in as a repo admin.

Check once, **before any work** (a missing scope found at push time means redoing steps):
```bash
gh auth status && gh api "repos/OWNER/REPO" --jq .permissions.admin
git remote get-url origin
```
- **Scopes** (the "Token scopes" line): `repo` is needed for the settings, the deploy key and secrets. `workflow` is needed to push changes to `.github/workflows/` when the remote is `https://` (pushes over `git@github.com:`/SSH don't need it). If one is missing, ask the user to run `gh auth refresh -h github.com -s workflow` (it opens the browser), then check again.
- **HTTPS pushes:** if `git push` can't authenticate over `https://`, push once with the GitHub CLI's credentials: `git -c credential.helper='!gh auth git-credential' push -u origin BRANCH`. `gh auth setup-git` makes that permanent, but it changes the user's global git config, so only with their yes.
If `gh` is missing, not signed in, or not an admin (common in cloud sessions), don't stop:
- finish everything that needs only `git`, and open the PR if you can (otherwise push the branch and give the user the compare URL);
- then tell the user to run the settings themselves, on a computer where `gh auth login` is done, from a checkout of the repo:
  ```bash
  bin/setup-github.sh OWNER/REPO --linked-issue on   # or off, as chosen
  ```
  plus any `gh variable set` / `gh secret set` commands the command would have run;
- say clearly which settings are not applied yet. Until they are, `main` is unprotected and the release workflow pushes with the workflow token instead of the deploy key.

## Working rules

- **Credits:** commits and PRs carry only the user's own git identity. Never add a Co-Authored-By trailer, a "Generated with" footer or a session link, and never commit as a bot user.
- **Branch names:** short and descriptive (e.g. `repo-standard`). Never prefixed with the assistant's name.
- **Issues and PRs:** one GitHub issue per change. All changes from one request go in one PR that closes every issue, with one `Closes #N` line per issue. Squash-merge.
  - In a repo whose linked-issue switch is off (`REQUIRE_LINKED_ISSUE=false`), PRs need no issue and the release changelog uses PR titles instead. Open issues anyway unless the user says not to, and always write PR titles that read well as changelog lines.
  - A risky change unrelated to the rest (e.g. code restructuring) gets its own PR, so it can be reverted alone.
- **Skip markers:** never write `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]` or `[actions skip]` in a PR title or body, not even quoted. The squash commit inherits it and GitHub then skips every workflow, including the release.
- **`main`:** never push to it directly. The only exception is the very first commit of a brand-new repo in `/wp-repo-standard:new`.
- **Secrets:** never ask the user to paste a secret value into the chat. Give them the exact `gh secret set NAME --repo OWNER/REPO` command to run themselves.
- **Outward-facing steps:** creating a repo, applying GitHub settings, creating a deploy key, opening or merging a PR. Confirm each one first, unless the user already asked for it in this conversation.
- **CI:** after opening a PR, check CI once and report the result. Don't poll in a loop, and merge only when the user asks.

## What the standard gives a repo

- **Ignore files:** `.gitignore`, plus `.distignore`, which decides what ships (the zip and deploys).
- **Automatic releases:** `release.yml` and `.github/scripts/`. On each merge to `main`, the workflow builds the zip and compares it with the zip of the last release tag. Only if they differ (docs, CI, config and `.distignore`-only changes leave it identical) does it release:
  1. bumps the version: patch by default, or minor/major with the `release:minor` or `release:major` label;
  2. writes the version and changelog into the plugin header (or `style.css` for a theme) and `readme.txt`;
  3. commits that to `main`;
  4. tags it and publishes a GitHub release with the zip.
- **Deploys:** `deploy.yml`, with an on/off switch. It deploys only while the repo variable `DEPLOY_ENABLED` is `true`, which is off by default. `DEPLOY_METHOD` picks the target: `ftps`, `ssh` or `wporg`.
- **Linked issue check:** `linked-issue.yml`. A PR must close an issue, and the release changelog is built from those issues. It has an on/off switch, the repo variable `REQUIRE_LINKED_ISSUE`: on unless it is `false`. When off, the check still runs but always passes (so the required check stays green), and the changelog uses PR titles. On is the standard; off suits repos that don't want an issue for every PR.
- **Dependabot** for GitHub Actions.
- **Setup script:** `bin/setup-github.sh` applies the GitHub settings that templates don't copy:
  - squash-only merges;
  - the release labels;
  - `DEPLOY_ENABLED=false`;
  - `REQUIRE_LINKED_ISSUE` from `--linked-issue on|off`. Without the flag an existing value is kept, and an unset one stays on. The script only asks when run in a terminal, and it never is when you run it, so always pass the flag when the user made a choice;
  - a `release-bot` deploy key, which the release workflow uses to push its version commit;
  - a "Protect main" ruleset: no deletion, no force-push, PRs required, the "Linked issue" check required, plus the "CI" check when the repo has `ci.yml`. Repo admins and deploy keys may bypass it. On a private repo, rulesets need a paid GitHub plan (Pro, Team or Enterprise); the script says so and stops if GitHub refuses;
  - private vulnerability reporting (the "Report a vulnerability" button `SECURITY.md` points to; GitHub allows it on public repos).
- **Tooling** (optional when adopting): CI (`ci.yml`: PHP syntax and unit tests, PHPCS, PHPStan, JS/CSS lint, block build, WordPress Plugin Check), coding standards, static analysis (`phpstan.neon.dist`, `tests/phpstan/bootstrap.php`), a local Docker environment.
  - Plugin Check fails while `readme.txt` "Tested up to" is behind the latest WordPress, and on code WordPress.org would reject.
- **Community files** (optional): `CONTRIBUTING.md`, `SECURITY.md`, issue forms (`.github/ISSUE_TEMPLATE/`) and a PR template with `Closes #`.
- **Playground demo** (optional): `.wordpress-org/blueprints/blueprint.json` plus a "Try it in your browser" link. It installs `releases/latest/download/<slug>.zip`, so it only works for a public repo that has a release.
