---
name: adopt
description: Bring an existing WordPress plugin or theme repo up to the wordpress-plugin-boilerplate standard. It adds ignore files, automatic versioned releases, a deploy workflow with an on/off switch, a linked-issue check, Dependabot and a protected main. Code restructuring is only proposed. Use when the user runs /wp-repo-standard:adopt or asks to standardize or adopt the standard in an existing repo.
argument-hint: "[path to repo, default: current folder]"
---

# /wp-repo-standard:adopt

First read `${CLAUDE_PLUGIN_ROOT}/rules.md`, and follow it throughout.

The goal is to add the standard files and settings automatically. Code changes are only **proposed**. Work in the repo given as `$ARGUMENTS`, or in the current folder if none is given.

## 1. Audit
1. Download the standard ("Download the standard" in the rules).
2. Work through `${CLAUDE_PLUGIN_ROOT}/skills/adopt/audit.md`, every section, and give the user the report.

Then read the boilerplate's `README.md` in `$STD` ("How changes ship", "Deploys"), so you can explain the flow.

Stop and explain if any of these is true:
- **Not WordPress:** the audit found no WordPress plugin or theme. The standard doesn't cover it; offer to adapt it by hand.
- **Not root layout:** the plugin or theme sits in a subfolder. The release scripts need it at the repo root. Moving it is a restructuring, so propose it (step 6), and continue only after the user says yes and that move is merged.
- **No admin rights:** the user isn't an admin of the GitHub repo, so only an admin can apply the settings. Offer to do the file work and PR anyway, and hand the settings commands to an admin.

If only this session can't reach GitHub as an admin (no `gh`, not signed in, a cloud session) but the user is an admin, don't stop: follow "Where it runs" in the rules.

## 2. One round of questions
Ask everything in one round, with the recommended answer first. A question tool may take only a few questions per call (AskUserQuestion: 4): group them, for example the optional groups (tooling, community files, Playground) as one multi-select, or use two calls back to back. Skip questions that don't apply.
- **Linked-issue rule:** must every PR close an issue?
  - *on* (recommended, the standard): the changelog lists the closed issues;
  - *off*: PRs need no issue; the check always passes and the changelog uses PR titles.

  If the audit found `REQUIRE_LINKED_ISSUE` already set, don't ask: keep that value and tell the user, unless they ask to change it.
- **Deploy target:**
  - *none for now* (recommended);
  - *ftps*;
  - *ssh*;
  - *wporg*. Plugins only: themes aren't deployed to WordPress.org by SVN.

  `DEPLOY_ENABLED` stays `false` whatever they choose.
- **Tooling group:** add CI, coding standards, PHPStan, local Docker and the pre-submission checks from the boilerplate? Warn that existing code may fail the jobs: With `ci.yml` in the repo, the ruleset requires the "CI" check, so a failing job blocks every merge until it's fixed or made report-only.
  - PHPCS and PHPStan usually report many issues in older code. Offer to keep either job report-only (`continue-on-error: true`) or to drop it.
  - Plugin Check fails if `readme.txt` "Tested up to" is behind the latest WordPress (the audit says) and on anything WordPress.org would reject. Offer to drop the job for private client plugins.
  - JS/CSS lint usually reports many issues too (mostly formatting, which `npm run format` fixes). Same choice: blocking, report-only or dropped.
  - Say which boilerplate-only parts will be left out, from the audit's "Code shape": the block build, integration tests, the rename job.
- **Community files:** add `CONTRIBUTING.md`, `SECURITY.md`, the issue forms and the PR template? Recommended for public repos; optional for private ones.
- **Playground demo:** only for a public plugin. Add the blueprint and a "Try it in your browser" link? It works once the repo has a release.
- **Version mismatch:** only if the audit warned that the header version is ahead of the latest tag. How should they be lined up? For example, a `release:minor` or `release:major` label on this PR, or correcting the header.
- **Old workflows:** only if the audit found workflows that aren't in the standard. Replace or keep each one. An old release or deploy workflow must go, or every change would be released twice.
- **Classic branch protection:** only if present. Replace it with the ruleset?
- **readme.txt details:** only if the repo has no `readme.txt`. The WordPress.org username(s) for `Contributors` (optional; leave a placeholder if none), and confirm `Requires at least`, `Requires PHP` and `Tested up to` (offer values from the README or code, and the latest WordPress from the audit).

## 3. Issues
Create one issue per change you'll actually make. Each body says what's wrong now and the expected outcome. A typical set:
- **Standard ignore files:** `.gitignore`, and `.distignore` deciding what ships.
- **Automatic releases:** `release.yml` and `.github/scripts/`, including the `readme.txt` Stable tag and changelog.
- **Deploy workflow:** off by default, naming the chosen target.
- **Linked issue check on PRs:** the workflow, with the chosen on/off setting.
- **Dependabot for GitHub Actions.**
- **GitHub setup script:** `bin/setup-github.sh`.
- **WordPress skills for Claude:** plugins only, when the standard has them (audit section 5).
- **Tooling group:** if chosen (name PHPStan and Plugin Check in it, and any job kept report-only).
- **Community files:** if chosen.
- **Playground demo:** if chosen.
- **Tested up to:** if the audit says it's behind, as its own issue (bump it after testing on the latest WordPress).
- **Remove old workflows:** if chosen.

## 4. Branch and files
Create a branch from an up-to-date default branch, e.g. `git switch -c repo-standard`. Then:
- **Copy as-is** from `$STD`:
  - `.github/workflows/release.yml`, `deploy.yml` and `linked-issue.yml`;
  - `.github/scripts/*`;
  - `.github/dependabot.yml`;
  - `bin/setup-github.sh` (keep it executable);
  - for a plugin, the WordPress skills from `$STD/.claude/skills/` as whole folders: `wp-plugin-development` always, and `wp-plugin-directory-guidelines` for a public plugin or a WordPress.org deploy. They replace any older copy of the same folder; other skills in `.claude/skills/` stay. `.distignore` already keeps `/.claude` out of the zip.
- **Merge** each of `.gitignore` and `.distignore`:
  as "Merge an ignore file" in the rules describes, including reading the "Project-specific" block afterwards.
- **`readme.txt`:**
  - A plugin needs a `Stable tag:` equal to the header version, plus an `== Changelog ==` section.
  - A theme needs `== Changelog ==` only.
  - If the file is missing, create one in WordPress readme format from the header fields and the answers in step 2. Seed `== Changelog ==` with the earlier versions you can find in tags or commit messages, newest first, so the history isn't lost.
  - An entry for the current header version may stay: with no tags, the first release is that version, and the release keeps an existing `= X.Y.Z =` entry instead of adding a second one.
  - Keep every existing changelog entry.
- **Header `Version:`** must be `X.Y.Z`. Fix it if it isn't, and say so.
- **Plain blocks** (the audit's "Code shape" found `block.json` in `blocks/` and no build): in the merged `.distignore`, comment out `/blocks` with a note (`# /blocks  - kept: this plugin's blocks are plain JS, no build step`). This is the one allowed edit to the standard part. Exclude only what really is source, if anything.
- **Tooling group** (if chosen):
  - Copy the files, including `phpstan.neon.dist` and `tests/phpstan/bootstrap.php`.
  - Adapt the names to this repo: composer `name`, the `.env.example` slug, the `paths` in `phpstan.neon.dist`, and the constants in `tests/phpstan/bootstrap.php` (the ones the main plugin file defines).
  - **Fit `phpcs.xml.dist`:**
    - `text_domain`: the plugin's Text Domain (or slug).
    - `prefixes`: the plugin's real function/option/hook prefix; keep a namespace element only if the plugin uses a PHP namespace (its own, never `WPGenius\MyPlugin`).
    - `minimum_wp_version` = `Requires at least`, and `testVersion` = `Requires PHP` followed by `-` (e.g. `7.4-`), from the plugin header or `readme.txt`.
    - The `src/` and `tests/` rules (FileName exclusions, test-only comment rules, the test bootstraps) are for the boilerplate's autoloaded layout: drop them, or point them at this plugin's folders, for a classic `includes/class-*.php` plugin.
  - **Fit `ci.yml` to this plugin.** The boilerplate's file tests the boilerplate's own layout. Remove what doesn't apply, and remove the same job names from the `needs:` list of the final `ci` job (otherwise it waits on jobs that don't exist):
    - `rename`: always remove; it tests the boilerplate's `bin/rename.sh`.
    - Unit tests: without them (audit's "Code shape"), remove `composer test` from the PHP job and name it "PHP <version> syntax"; in `composer.json` drop `phpunit/phpunit`, `brain/monkey`, `yoast/phpunit-polyfills`, the `test` script and `autoload-dev`; don't copy `phpunit.xml.dist`, `tests/bootstrap.php`, `tests/TestCase.php` or `tests/Unit`.
    - `integration`: remove unless the plugin has integration tests (`tests/Integration`, `phpunit-integration.xml.dist`).
    - `js-css-lint`: without a build step, remove its `npm run build` and "build/ is committed" steps and rename it "JS/CSS lint"; without any JS or CSS, remove the job.
    - Then check the YAML (`actionlint` if installed) and that every name in `needs:` is a job that exists.
  - **Fit `package.json`:** without a build step or integration tests, keep only `@wordpress/scripts` and the `lint`, `lint:js`, `lint:css` and `format` scripts (pointed at this plugin's JS and CSS folders), and drop `build`, `start`, `env`, `test:integration*` and the block, interactivity and `@wordpress/env` dependencies. Likewise drop `.wp-env.json` and the integration PHPUnit config if copied.
  - **Pre-submission checks:** copy `bin/presubmit/` (keep `run.sh` executable). They run Plugin Check and `WP_DEBUG` runs in WordPress Playground on the packaged files, for `/wp-repo-standard:submit`. With a build step, also copy `bin/asset-guard.js` and add `"postbuild": "node bin/asset-guard.js"` to `package.json`, so the generated `build/*.asset.php` files get the `ABSPATH` guard.
    - **Adapt them to this plugin:** copy `activate.php`, `plugin-check.php`, `runtime.php` and `run.sh` unchanged; they're generic, and the standard's `phpcs.xml.dist` excludes `bin/presubmit/` (keep that exclude when fitting it). Write only `bin/presubmit/plugin.php`, which returns an array of optional keys (its header comment explains each): `prefix` (default: the Text Domain with `-` as `_`), `setup` (create the content to show), `render` (this plugin's block markup and shortcodes), `check_render` (checks on the rendered HTML), `settings_page`, `before_deactivate`, `before_uninstall`, `after_uninstall`. Replace every boilerplate example in it with this plugin's own; remove keys that don't apply.
  - **Node:** if the audit found `node -v` older than the standard's `engines`, the lint tools crash. Ask the user to switch to the version in `.nvmrc` with their Node version manager, following that tool's own instructions, then continue. If they can't switch now, don't run the lint tools locally: say so in the PR, and let CI run them.
  - **Integrations:** if the audit found Elementor, WooCommerce or ACF code, PHPStan needs stubs for those classes: a stubs package where one exists (for example `php-stubs/woocommerce-stubs`, `php-stubs/acf-pro-stubs`) as a dev dependency listed under `scanFiles`, or a small stub file of the classes and methods the plugin uses, under `tests/phpstan/` and listed in `scanFiles`. Never `ignoreErrors` whole classes.
  - Run `composer phpstan` and `npm run lint` once each, and tell the user how many issues each reports, so the choice of blocking or report-only is informed.
  - Never copy the boilerplate's lock files. Ask the user to regenerate `composer.lock` and `package-lock.json` with their own Composer and npm, following those tools' instructions, and commit them.
- **Community files** (if chosen): copy them and replace `wpgenius/wordpress-plugin-boilerplate` (security link in `.github/ISSUE_TEMPLATE/config.yml`) and the boilerplate's name with this repo's.
- **Playground demo** (if chosen): copy `.wordpress-org/blueprints/blueprint.json`, replace the zip URL and slug, and add the "Try it in your browser" link to the README with this repo's raw URL. The `runPHP` step (it creates the boilerplate's example items and a page with its blocks) and `landingPage` are boilerplate-specific: rewrite them for this plugin, for example sample content it uses (its own shortcodes or blocks, sideloaded images) and landing on its admin or demo page.
  - Sample content must come from the blueprint itself, never from core files: Playground's WordPress build leaves some out (for example `wp-admin/images/`). Embed small files in the `runPHP` code instead (a tiny palette PNG is a few hundred base64 characters), write them with `file_put_contents()` to `wp_tempnam()`, then sideload them.
  - When a step returns `WP_Error` (`media_handle_sideload()`, `wp_insert_post()` and the like), `throw new Exception(...)` with its message, so the blueprint fails visibly instead of opening an empty demo.
  - Before the PR, ask the user to try the blueprint in WordPress Playground and check the landing page shows the sample content. Playground's documentation explains how to load a blueprint that isn't pushed yet; the hosted site can't fetch a `localhost` `blueprint-url`. Until the repo has a release, the zip step has nothing to install, so the full blueprint can only be tried after the first release.
- **Slug:** if the audit says the repo name isn't a valid slug, `PLUGIN_SLUG` must be set (step 7).
- **README:** add a short "How changes ship" section, adapted from the boilerplate's.

## 5. Verify before pushing
- **Script syntax:** run `bash -n` on every `.github/scripts/*.sh` and on `bin/setup-github.sh`, and `actionlint` if it's installed.
- **Package contents:** run "Preview the package" from the rules and show the user the file list.
  - The main file must be in it.
  - Nothing dev-only may ship.
  - Everything needed at runtime must ship, e.g. `build/`, `vendor/` for runtime dependencies, `languages/`.

  Fix `.distignore` until the list is right.
- **Ignored runtime files:** run the audit's section 8 check again, now with the merged `.gitignore`. Nothing under a runtime folder may be ignored; fix the rule and commit the missing files (they may be missing from `main` today).
- **PHP syntax:** run `find . -name '*.php' -not -path './vendor/*' -not -path './node_modules/*' -exec php -l {} \;`.
- **PHPCS really scans** (tooling group): `vendor/bin/phpcs --report=summary` must list the plugin's files. A clean run that checked 0 files means an exclude pattern matched the whole checkout; for example, an absolute `/.claude/*` pattern hides everything when the repo sits in a Claude worktree under `.claude/worktrees/`. Fix the pattern (the standard anchors its folder excludes to the repo root with `type="relative"`, such as `^.claude/*`; keep that when fitting `phpcs.xml.dist`), or run PHPCS from a checkout outside `.claude/`, before trusting the result. The list must not include `release/` either, where the pre-submission checks write a packaged copy.

## 6. Code restructuring: propose only
Compare the code with the boilerplate's current structure (its README's "What's in the box" and its `src/` folders). Write a short proposal: what you'd move or rename, why, and the risk.

For anything that changes behaviour, say what existing sites would notice: renamed hooks, options, classes or namespaces.

Do nothing until the user says yes. Then do it in its own issues and its own PR, after the standard PR.

## 7. GitHub settings
If this session has no admin `gh`, skip to the hand-off in "Where it runs" in the rules.

If the GitHub check in step 1 showed `"visibility": "private"`, warn first: rulesets on private repos need a paid GitHub plan (Pro, Team or Enterprise). On GitHub Free the script stops at the ruleset and `main` stays unprotected, unless the repo is made public.

Show what `bin/setup-github.sh` will do (from its header comment), and get a clear yes. Creating the deploy key needs explicit approval. Then run it with the linked-issue choice from step 2 (leave the flag out only when keeping an existing value):
```bash
bin/setup-github.sh OWNER/REPO --linked-issue on   # or off
```
Then, where needed:
- set `gh variable set PLUGIN_SLUG --body <slug>`;
- set `gh variable set DEPLOY_METHOD --body <method>` for the chosen target;
- give the user the `gh secret set …` commands for that target. The list is in the header of `deploy.yml`.

## 8. Pull request
Commit and push the branch. Open one PR that closes every issue. In the body:
- **Changes:** one line per change, under its issue.
- **Verification:** what you checked.
- **What happens on merge:**
  - With no tags yet, this merge publishes `v<header version>`: with the changelog entry `readme.txt` already has for that version, or "Initial release" if it has none.
  - With tags, it releases only if the zip changed compared with the last release (for example a `readme.txt` or header fix). Adding only workflows, scripts and ignore rules makes no release.
  - Deploys stay off until `DEPLOY_ENABLED=true`.

Check CI once and report. Merge only when asked. After the merge, check the Release run once, and report the release URL or the error.

## Already on the standard?
Run this again to update. The audit lists the files that `differ` from the standard this plugin version is pinned to (update the plugin first to get the newest). Update them the same way, through issues and one PR.

## Last: report problems with this plugin
If this run hit problems in the plugin or the standard (not in the repo), follow "Report problems with this plugin" in the rules.
