# Changelog

## 0.9.1

Maintenance release: no runtime behavior changes.

### Documentation

- Add a gemspec description and RubyGems metadata (homepage, source code,
  bug tracker, and changelog links), and lead the README with the same
  one-line description (#127)

## 0.9.0

### Bug fixes

- Apply the site's `baseurl` to links rewritten in includes, fixing project
  pages served from `/repo/` (#125)
- Resolve links to pages added during `jekyll serve` rebuilds (#125)
- The `rellinks` filter now rewrites links whose `href` isn't the first
  attribute (#125)

### Performance

- Resolve link targets through one per-site index instead of scanning every
  page for each link (#125)

### Removed

- The internal `JekyllRelativeLinks::Context` class, and `process_link`, which
  was unintentionally exposed as a Liquid filter (#125)

### Dependencies

- Declare `required_ruby_version >= 3.0` (#117)

### Infrastructure

- Bump `github/codeql-action` (#118, #122)

## 0.8.0

### Features

- Add a `rellinks` Liquid filter that rewrites relative links in already-
  markdownified content — usable as `{{ content | markdownify | rellinks }}`,
  so links inside included fragments get converted (#98)

### Bug fixes

- Convert relative links in Jekyll includes that were previously skipped (#104)
- Handle hex-encoded (`%20`) spaces in relative link paths (#106)
- Correctly handle images nested inside Markdown links (#107)
- Fix an error when a page's YAML front matter has an `excerpt:` field (#97)

### Performance

- Use an O(1) hash lookup in `url_for_path`, speeding up link resolution on
  large sites (#110)

### Documentation

- Document that line-wrapped links are not processed, per the CommonMark spec
  (#105)

### Infrastructure

- Modernize CI — Ruby 3.3 & 4.0 against Jekyll 3.x & 4.x — and bump
  rubocop-rspec to `~> 3.0` (#115)
- Enable Dependabot for GitHub Actions; bump `actions/checkout`,
  `github/codeql-action`, and `rubocop-factory_bot` (#111, #112, #113, #114)
