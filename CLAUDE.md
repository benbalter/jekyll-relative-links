# CLAUDE.md

Jekyll plugin that turns relative links to `.md` files into working HTML links, like on GitHub. Published to RubyGems as [`jekyll-relative-links`](https://rubygems.org/gems/jekyll-relative-links).

## Commands

- [`script/bootstrap`](script/bootstrap) installs dependencies.
- Run [`script/cibuild`](script/cibuild) before committing. It runs RSpec, RuboCop and `gem build`, as [CI](.github/workflows/ci.yml) does.
- CI also tests Jekyll 3 and 4. Set `JEKYLL_VERSION` (for example `JEKYLL_VERSION="~> 3.0"`) before `script/bootstrap` and `script/cibuild` to match a CI job.

## Releasing

- Pushing a `v*` tag runs [`release.yml`](.github/workflows/release.yml), which publishes the gem to RubyGems immediately and creates a GitHub Release. A published version can't be replaced.
- The owner cuts releases with [jekyll-release-tools](https://github.com/benbalter/jekyll-release-tools), and only after explicitly approving the release.
- When asked, agents may prepare a version-bump PR that updates [`lib/jekyll-relative-links/version.rb`](lib/jekyll-relative-links/version.rb) and [`CHANGELOG.md`](CHANGELOG.md).
- Agents never create or push tags, run `rake release` or `gem push`, or create a GitHub Release.
- Push branches with `git push --no-follow-tags`, so an annotated tag on a commit doesn't go out with the branch.
