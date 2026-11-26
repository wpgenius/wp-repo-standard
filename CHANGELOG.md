# Changelog

Written by the release workflow: one entry per release, one line per issue it closed.

## 1.1.15 (2026-11-26)

* Check that PHPCS scanned files (#66)

## 1.1.14 (2026-11-26)

* Report adopt/new problems back to wp-repo-standard (#44)

## 1.1.13 (2026-11-26)

* Pin the standard to boilerplate main after v2.0.10 (#63)

## 1.1.12 (2026-11-26)

* Adapt the pre-submission scripts and check unguarded asset files (#61)

## 1.1.11 (2026-11-26)

* Remove the icon from the plugin folder until the organisation is verified (#58)

## 1.1.10 (2026-11-26)

* Pin the downloaded standard to a checked commit (#55)
* Reword the remaining download-and-run lines in adopt (#56)

## 1.1.9 (2026-11-26)

* Use the boilerplate's pre-submission scripts and asset guard (#53)

## 1.1.8 (2026-11-26)

* Adopt and new add the WordPress agent skills (#50)
* Add /wp-repo-standard:submit for WordPress.org submissions (#51)

## 1.1.7 (2026-11-26)

* Remove the download-and-run Node command from adopt (#48)

## 1.1.6 (2026-11-15)

* Playground blueprint: no core-file sample content, run it once before the PR (#39)
* Check that Plugin URI differs from Author URI (#40)

## 1.1.5 (2026-11-15)

* Replace the plugin icon with the stacked-layers design (#37)

## 1.1.4 (2026-11-15)

* adopt: fit the tooling to plugins without unit tests (#31)
* adopt: spell out how to fit phpcs.xml.dist (#32)
* adopt: exact command to run npm under a newer Node (#33)
* adopt: Playground blueprint content is boilerplate-specific (#34)
* adopt: say how the first release treats an existing changelog entry (#35)

## 1.1.3 (2026-11-15)

* adopt: fit the tooling ci.yml and package.json to the plugin (#23)
* adopt: plain-JS blocks are excluded by the standard .distignore (#24)
* audit: catch ignored files the plugin needs at runtime (#25)
* Check gh scopes and HTTPS push credentials before any work (#26)
* adopt: check the Node version before npm lint (#27)
* adopt: PHPStan stubs for plugins that extend other plugins (#28)
* adopt: question round doesn't fit a 4-question tool (#29)

## 1.1.2 (2026-11-14)

* Ignore-file merge leaves no .distignore when the repo has none (#19)
* Audit: branch protection check prints a GitHub error (#20)
* adopt: ask for readme.txt details when creating one (#21)

## 1.1.1 (2026-11-14)

* Support the boilerplate's linked-issue on/off switch (#16)
* new: ask for Contributors and minimal or full examples (#17)

## 1.1.0 (2026-11-14)

* Directory refused v1.0.2: the plugin ships script files (#13)
* Put the plugin in its own subfolder (#14)

## 1.0.2 (2026-11-14)

* Directory review: scripts run code from the downloaded standard (#8)
* Directory review: scripts use the user's GitHub login (#9)

## 1.0.1 (2026-11-14)

* Require CI to pass before a PR can merge (#3)
* Fail the release when GitHub lookups fail (#4)
* Release guard skips any commit titled "Release v…" (#5)
* Skills: warn that private repos need a paid plan for rulesets (#6)

## 1.0.0 (2026-11-14)

* Initial release.
