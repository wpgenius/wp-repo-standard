# Audit checklist

Read-only: change nothing while auditing. Run each check from the repo's root, with `$STD` from "Download the standard" in the rules. Then report the results to the user in these sections, in this order.

## 1. Type and layout
```bash
for f in $(find . -maxdepth 1 -name '*.php' | sort); do head -n 30 "$f" | grep -qiE '^[[:space:]/*#@]*Plugin Name:' && echo "plugin: ${f#./}"; done
head -n 30 style.css 2>/dev/null | grep -qiE '^[[:space:]/*#@]*Theme Name:' && echo "theme: style.css"
```
- A root `.php` file with `Plugin Name:` means a **plugin**, and that file is the main file. Otherwise `style.css` with `Theme Name:` means a **theme**.
- If neither is in the root, look one level deeper:
  ```bash
  grep -rliE --include='*.php' --include=style.css --exclude-dir={.git,vendor,node_modules} '^[[:space:]/*#@]*(Plugin|Theme) Name:' . | head -n 5
  ```
  A hit means **not root layout**: the release scripts need the plugin or theme at the repo root. No hit at all means it isn't a WordPress plugin or theme.

## 2. Slug (the zip folder name)
```bash
git remote get-url origin
grep -m1 -iE '^[[:space:]/*#@]*Text Domain:' MAIN_FILE
```
- Take `OWNER/REPO` from the github.com remote URL (https or ssh form, without `.git`).
- The repo name works as the slug if it's lowercase letters, digits and hyphens, and equals the Text Domain (when there is one). Otherwise the repo variable `PLUGIN_SLUG` must be set to the Text Domain.

## 3. Versions
```bash
grep -m1 -iE '^[[:space:]/*#@]*Version:' MAIN_FILE
git tag --list 'v*' --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1
git tag --list | grep -vE '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 5
```
- The header `Version:` must be `X.Y.Z`. If it isn't, the first automatic release falls back to 1.0.0 unless it is fixed.
- **No `vX.Y.Z` tag:** the first merge after setup releases `v<header version>` ("Initial release").
- **With a tag:** the next release is its patch bump (or minor/major by label), and only on a merge that changes the zip. If the header version is *ahead* of that next version, warn: the user must choose how to line them up (a `release:minor`/`release:major` label on the PR, or correcting the header).
- Other tags are ignored by the release workflow; mention them.

## 4. readme.txt
```bash
grep -iE '^(Stable tag|Tested up to):' readme.txt; grep -c '^== Changelog ==' readme.txt
curl -fsS --max-time 10 https://api.wordpress.org/core/version-check/1.7/ | grep -oE '"current":"[0-9]+\.[0-9]+' | head -n 1
```
- Missing `readme.txt`: the release writes the changelog there, so one must be created.
- **Plugin:** needs `Stable tag:` and `== Changelog ==`. **Theme:** needs `== Changelog ==` only.
- `Tested up to:` older than the latest WordPress (the `curl` result) makes Plugin Check in the tooling group fail until it's bumped after testing. Missing entirely also fails it, for plugins.

## 5. Standard files
```bash
for f in .github/workflows/release.yml .github/workflows/deploy.yml .github/workflows/linked-issue.yml \
  .github/scripts/lib.sh .github/scripts/release-plan.sh .github/scripts/stamp-version.sh \
  .github/dependabot.yml bin/setup-github.sh .gitignore .distignore; do
  if [ ! -f "$STD/$f" ]; then echo "not in standard  $f"; elif [ ! -f "$f" ]; then echo "missing          $f"
  elif cmp -s "$STD/$f" "$f"; then echo "same             $f"; else echo "differs          $f"; fi
done
```
The first eight are copied as-is; the two ignore files are merged. `differs` on an already-adopted repo means the standard has moved on: update them.

## 6. Optional groups
```bash
for f in .github/workflows/ci.yml composer.json phpcs.xml.dist phpstan.neon.dist tests/phpstan/bootstrap.php phpunit.xml.dist \
  package.json .nvmrc .editorconfig .env.example docker-compose.yml \
  CONTRIBUTING.md SECURITY.md .github/pull_request_template.md .github/ISSUE_TEMPLATE/bug_report.yml \
  .github/ISSUE_TEMPLATE/feature_request.yml .github/ISSUE_TEMPLATE/config.yml .wordpress-org/blueprints/blueprint.json; do
  [ -f "$STD/$f" ] || continue; if [ -f "$f" ]; then echo "present  $f"; else echo "missing  $f"; fi
done
```
Group them for the user: **tooling** (CI, coding standards, static analysis, tests, local Docker), **community files**, and the **Playground demo** (public plugins with a release only).

## 7. Other workflows
```bash
for f in $(find .github/workflows -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | sort); do [ -f "$STD/$f" ] || echo "$f: $(sed -nE 's/^name:[[:space:]]*(.*)/\1/p' "$f" | head -n 1)"; done
```
Workflows that aren't in the standard. An old release or deploy workflow must go, or every change would be released twice.

## 8. GitHub settings
Only if the GitHub CLI is available (see "Where it runs" in the rules); otherwise say this part was skipped.
```bash
gh api repos/OWNER/REPO --jq '{visibility, admin: .permissions.admin, squash: .allow_squash_merge, merge_commit: .allow_merge_commit, rebase: .allow_rebase_merge}'
gh api repos/OWNER/REPO/rulesets --jq '[.[].name]'
gh api repos/OWNER/REPO/branches/main/protection --silent 2>/dev/null && echo "classic branch protection: yes" || echo "classic branch protection: no"
gh label list --repo OWNER/REPO --search release:
gh variable list --repo OWNER/REPO
gh secret list --repo OWNER/REPO
gh release list --repo OWNER/REPO --limit 20
```
- `REQUIRE_LINKED_ISSUE` in the variables: report it. Not set means the linked-issue rule is on; `false` means off (the check always passes and the changelog uses PR titles); anything else means on.
- Secret values are never readable; the list shows names only.
- Note draft releases: one named like a future version would clash with it.
- `"visibility": "private"` matters for step 7 of adopt: rulesets on private repos need a paid GitHub plan.
