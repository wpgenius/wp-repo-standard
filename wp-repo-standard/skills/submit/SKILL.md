---
name: submit
description: Prepare a WordPress plugin for the WordPress.org plugin directory and see it through review. It audits the code, readme and package against what reviewers flag, runs the repo's pre-submission checks, fixes findings through issues and one PR, says what to upload and drafts replies to review emails, then sets up WordPress.org deploys after approval. Use when the user runs /wp-repo-standard:submit or asks to submit, resubmit or get a plugin ready for WordPress.org.
argument-hint: "[path to repo, default: current folder]"
---

# /wp-repo-standard:submit

First read `${CLAUDE_PLUGIN_ROOT}/rules.md`, and follow it throughout.

Work in the repo given as `$ARGUMENTS`, or in the current folder if none is given. This is for **plugins** going to WordPress.org. The repo should already be on the standard; if it isn't (no `release.yml`), run `/wp-repo-standard:adopt` first, because the zip you upload comes from the release workflow.

The user does everything on WordPress.org themselves: uploading, replying to the review team, the SVN password. You prepare, check and draft; never sign in, upload or send for them.

## 1. Where it stands
Ask, or read from the conversation, which stage this is:
- **First submission:** go through every step.
- **Review email received:** the user pastes the email. Every point in it becomes an issue first (step 4), then run steps 2–3 again on the whole plugin, because reviewers check everything again on each upload.
- **Approved:** go to step 6.

Download the standard ("Download the standard" in the rules). Check that the repo has `.claude/skills/wp-plugin-development` and `.claude/skills/wp-plugin-directory-guidelines`. If the standard has them and the repo doesn't, or its copies differ, copying them is the first issue. Use both skills for the checks below: the guidelines skill for the 18 directory guidelines, naming and Plugin Check, the development skill for security and lifecycle.

## 2. Audit
Read every PHP file, the JS sources, `block.json` files, the plugin header and `readme.txt`, the way a reviewer would. Report each finding with file and line. Look for:

**Code**
- **Escaping at the point of output:** every `echo`/`printf`/`print` is escaped where it prints, including HTML built a few lines earlier. A `phpcs:ignore …OutputNotEscaped` comment is a finding unless core escapes the value (`get_block_wrapper_attributes()`, `wp_interactivity_data_wp_context()`). For renderer HTML, use a filterable allowed-HTML list (with `data-*`, ARIA attributes, `hidden`, `tabindex`, `style`) and `wp_kses()` at the echo.
- **Input:** sanitized on save; forms and actions check a nonce and a capability; settings have a sanitize callback.
- **SQL:** every query uses `$wpdb->prepare()` or the safe `$wpdb` helpers.
- **Assets:** no `<style>` or `<script>` printed into the page (`admin_head`, `wp_head`, templates). Use `wp_enqueue_*` with `wp_add_inline_style()` / `wp_add_inline_script()`, loaded only on the screens that need them.
- **Admin notices:** shown only on the Plugins screen, the Dashboard and the plugin's own pages.
- **Direct access:** every PHP file starts with `defined( 'ABSPATH' ) || exit;`, including generated `*.asset.php` (`uninstall.php` checks `WP_UNINSTALL_PLUGIN`).
- **Data:** the plugin changes only data it owns. A migration or recount touches only its own terms, posts and options.
- **Lifecycle:** deactivation clears scheduled events; uninstall removes options, transients and caches (and says what it keeps on purpose).
- **Versions:** editor and front-end scripts use the plugin's version constant, not a fixed `'1.0.0'`, so browsers load new files after updates.
- **Translations:** no `load_plugin_textdomain()` (WordPress.org language packs load on demand, and Plugin Check flags it). `block.json` has `textdomain`. The `.pot` scans `build/`, not the block sources `.distignore` drops, because JSON translations are matched against `build/<block>/index.js`.
- **Remote code:** no tracking, no code or assets loaded from other servers unless the readme discloses it (step 2, readme).

**readme.txt and header**
- **External services:** a section that names every outside address the plugin contacts, when (on save, on page view, by cron), what data it sends, and links to that service's terms and privacy policy. Check it against the code; it must be accurate.
- **Naming:** no trademarks in the name, slug, description or tags, and never "Gutenberg" (say "block editor").
- **Header in sync:** the header `Description:` matches the readme's short description (150 characters at most) and promises nothing the plugin doesn't do yet. `package.json` and `composer.json` descriptions too.
- **Plugin URI** differs from **Author URI**; WordPress.org's upload form refuses them when equal.
- **Contributors:** each is a real WordPress.org username (`https://profiles.wordpress.org/<name>/` exists).
- **Tested up to** is the current WordPress version; **Stable tag** equals the header `Version:`; at most 5 tags.
- **Changelog wording:** release changelog lines come from issue titles. Look at the titles of recent closed issues: they're user-facing, so no "Gutenberg" and no CI or tooling noise. Reword such issues before the next release, or label them `changelog:skip` if the repo's release script supports that label (`grep -n changelog:skip .github/scripts/release-plan.sh`).

**Licences**
- The plugin is GPL-2.0-or-later or compatible, with a licence file.
- Every bundled library (`assets/vendor/`, `src/vendor/`, copied files) has a GPL-compatible licence, a public human-readable source linked from the readme, and its own licence file. Libraries with commercial dual licences are a finding.
- **Minified builds:** list what `build/` bundles: the npm packages the JS sources import, and their dependencies (`node_modules/<package>/package.json` has `license`). Minifiers strip licence banners, so MIT, BSD and similar notices must ship in a `THIRD-PARTY-NOTICES.txt` (or the boilerplate's equivalent) linked from the readme.
- `.distignore` mustn't drop a library's README or licence: unanchored `README.md` lines match every folder; anchor them as `/README.md`.

**Package**
Run "Preview the package" from the rules on the latest release tag's contents, or on `main`. The main file, `build/`, `languages/` and bundled libraries with their licences must be in it; nothing dev-only.

## 3. Checks
- **Plugin Check:** with the experimental checks, on the packaged files, not the repo. CI's Plugin Check job covers the basic run; read its last result.
- **Runtime:** a clean site with `WP_DEBUG` on, on the lowest and highest PHP the plugin supports: activation prints nothing, the front end, settings pages and blocks render, uninstall cleans up, and the debug log stays empty.

Use the repo's own pre-submission scripts if it has them (the boilerplate's README names them). If it has none, say which checks couldn't run, and offer to add the boilerplate's scripts through `/wp-repo-standard:adopt`. Report every result with numbers (checks run, errors, warnings, notices).

## 4. Fix
Follow the working rules: one issue per finding, all fixes in one PR, merge only when the user asks. Title each issue as the changelog line it becomes. Each fix gets tested before the PR (the checks in step 3, or the part of them it affects).

After the merge, the release workflow publishes the new version and its zip. Run steps 2–3 on that release's zip before telling the user it's ready.

## 5. Submit or reply
- **Upload:** the `<slug>.zip` from the latest GitHub release, never a zip built by hand. Use the same WordPress.org account as any earlier submission. The user uploads it at wordpress.org/plugins/developers/add/, or on the plugin's review page for a resubmission.
- **Ownership:** a plugin under a company name needs proof: the WordPress.org account email on the company's domain, or the DNS TXT record the review team asks for. Tell the user before they submit.
- **Slug:** the review team can still change the slug before approval; ask them in the reply. It can't change after.
- **Review replies:** draft a reply in the same email thread: the version uploaded, then each point the reviewers raised with what changed, then other improvements, then the checks run. Keep it factual. The user sends it; the upload must happen before the reply says it's there.
- **Optional, screenshots:** if the readme lists screenshots, the images go in `.wordpress-org/` as `screenshot-1.png` and so on, matching the captions in order.

## 6. After approval
The review team emails the SVN address `https://plugins.svn.wordpress.org/<slug>/`. Then:
1. **SVN password:** the user creates it on their WordPress.org profile (Account & Security). It's separate from the login.
2. **Secrets:** the user adds `SVN_USERNAME` (WordPress.org username) and `SVN_PASSWORD` as repo secrets. You never handle the password; give them `gh secret set SVN_PASSWORD --repo OWNER/REPO`, which prompts for the value, or point them to Settings → Secrets and variables → Actions.
3. **Variables:** `gh variable set DEPLOY_METHOD --body wporg`, and `WPORG_SLUG` only if the WordPress.org slug differs from `PLUGIN_SLUG` or the repo name.
4. **Directory images** in `.wordpress-org/`, through an issue and PR: `icon-128x128.png` and `icon-256x256.png`, `banner-772x250.png` and `banner-1544x500.png`, and the screenshots. The deploy uploads them to SVN `assets/`.
5. **Test the connection:** run the Deploy workflow by hand with "deploy" unticked. It only checks SVN access.
6. **Switch on:** `gh variable set DEPLOY_ENABLED --body true`, with the user's yes, then run Deploy for the latest release with "deploy" ticked. From then on, every release deploys to WordPress.org on its own.

Check the Deploy run once and report the result, and the plugin page `https://wordpress.org/plugins/<slug>/` once it's live.
